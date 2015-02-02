//
//  PanoramaView.m
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <OpenGLES/ES1/gl.h>
#import <GLKit/GLKit.h>
#import "PanoramaView.h"

#define FPS 60
#define FOV_MIN 1
#define FOV_MAX 155
#define Z_NEAR 0.1f
#define Z_FAR 100.0f

// LINEAR for smoothing, NEAREST for pixelized
#define IMAGE_SCALING GL_LINEAR  // GL_NEAREST, GL_LINEAR

// this appears to be the best way to grab orientation. if this becomes formalized, just make sure the orientations match
#define SENSOR_ORIENTATION [[UIApplication sharedApplication] statusBarOrientation] //enum  1(NORTH)  2(SOUTH)  3(EAST)  4(WEST)

// this really should be included in GLKit
GLKQuaternion GLKQuaternionFromTwoVectors(GLKVector3 u, GLKVector3 v){
    GLKVector3 w = GLKVector3CrossProduct(u, v);
    GLKQuaternion q = GLKQuaternionMake(w.x, w.y, w.z, GLKVector3DotProduct(u, v));
    q.w += GLKQuaternionLength(q);
    return GLKQuaternionNormalize(q);
}

@interface Sphere : NSObject

-(bool) execute;
-(id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius textureFile:(NSString *)textureFile;
-(void) swapTexture:(NSString*)textureFile;
-(CGPoint) getTextureSize;

@end

@interface PanoramaView (){
    Sphere *sphere, *meridians;
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
    UIPanGestureRecognizer *panGesture;
    GLKMatrix4 _projectionMatrix, _attitudeMatrix, _offsetMatrix;
    float _aspectRatio;
    GLfloat circlePoints[64*3];  // meridian lines
}
@end

@implementation PanoramaView

-(id) init{
// it appears that iOS already automatically does this switch, stored in UIScreen mainscreen bounds
//    CGRect frame = [[UIScreen mainScreen] bounds];
//    if(SENSOR_ORIENTATION == 3 || SENSOR_ORIENTATION == 4){
//        return [self initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width)];
//    } else{
//        return [self initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
//    }
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}
- (id)initWithFrame:(CGRect)frame{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    return [self initWithFrame:frame context:context];
}
-(id) initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDevice];
        [self initOpenGL:context];
        sphere = [[Sphere alloc] init:48 slices:48 radius:10.0 textureFile:nil];
        meridians = [[Sphere alloc] init:48 slices:48 radius:8.0 textureFile:@"equirectangular-projection-lines.png"];
    }
    return self;
}
-(void) didMoveToSuperview{
// this breaks MVC, but useful for setting GLKViewController's frame rate
    UIResponder *responder = self;
    while (![responder isKindOfClass:[GLKViewController class]]) {
        responder = [responder nextResponder];
        if (responder == nil){
            break;
        }
    }
    if([responder respondsToSelector:@selector(setPreferredFramesPerSecond:)])
        [(GLKViewController*)responder setPreferredFramesPerSecond:FPS];
}
-(void) initDevice{
    motionManager = [[CMMotionManager alloc] init];
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [pinchGesture setEnabled:NO];
    [self addGestureRecognizer:pinchGesture];
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setEnabled:NO];
    [self addGestureRecognizer:panGesture];
}
-(void)setFieldOfView:(float)fieldOfView{
    _fieldOfView = fieldOfView;
    [self rebuildProjectionMatrix];
}
-(void) setImage:(NSString*)fileName{
    [sphere swapTexture:fileName];
}
-(void) setTouchToPan:(BOOL)touchToPan{
    _touchToPan = touchToPan;
    [panGesture setEnabled:_touchToPan];
}
-(void) setPinchToZoom:(BOOL)pinchToZoom{
    _pinchToZoom = pinchToZoom;
    [pinchGesture setEnabled:_pinchToZoom];
}
-(void) setOrientToDevice:(BOOL)orientToDevice{
    _orientToDevice = orientToDevice;
    if(motionManager.isDeviceMotionAvailable){
        if(_orientToDevice)
            [motionManager startDeviceMotionUpdates];
        else
            [motionManager stopDeviceMotionUpdates];
    }
}
#pragma mark- OPENGL
-(void)initOpenGL:(EAGLContext*)context{
    [(CAEAGLLayer*)self.layer setOpaque:NO];
    _aspectRatio = self.frame.size.width/self.frame.size.height;
    _fieldOfView = 45 + 45 * atanf(_aspectRatio); // hell ya
    [self rebuildProjectionMatrix];
    _attitudeMatrix = GLKMatrix4Identity;
    _offsetMatrix = GLKMatrix4Identity;
    [self customGL];
    [self makeLatitudeLines];
}
-(void)rebuildProjectionMatrix{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat frustum = Z_NEAR * tanf(_fieldOfView*0.00872664625997);  // pi/180/2
    _projectionMatrix = GLKMatrix4MakeFrustum(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    glMultMatrixf(_projectionMatrix.m);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glMatrixMode(GL_MODELVIEW);
}
-(void) customGL{
    glMatrixMode(GL_MODELVIEW);
//    glEnable(GL_CULL_FACE);
//    glCullFace(GL_FRONT);
//    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}
-(void)draw{
    static GLfloat whiteColor[] = {1.0f, 1.0f, 1.0f, 1.0f};
    static GLfloat clearColor[] = {0.0f, 0.0f, 0.0f, 0.0f};
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glPushMatrix(); // begin device orientation

        _attitudeMatrix = GLKMatrix4Multiply([self getDeviceOrientationMatrix], _offsetMatrix);
        [self updateLook];
    
        glMultMatrixf(_attitudeMatrix.m);
    
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, whiteColor);  // panorama at full color
        [sphere execute];
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, clearColor);
//        [meridians execute];  // semi-transparent texture overlay (15° meridian lines)

//TODO: add any objects here to make them a part of the virtual reality
//        glPushMatrix();
//        // object code
//        glPopMatrix();
    
        // touch lines
        if(_showTouches && _numberOfTouches){
            glColor4f(1.0f, 1.0f, 1.0f, 0.5f);
            for(int i = 0; i < [[_touches allObjects] count]; i++){
                glPushMatrix();
                    CGPoint touchPoint = CGPointMake([(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].x,
                                                     [(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].y);
                    [self drawHotspotLines:[self vectorFromScreenLocation:touchPoint inAttitude:_attitudeMatrix]];
                glPopMatrix();
            }
            glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
        }
    
    glPopMatrix(); // end device orientation
}
#pragma mark- ORIENTATION
-(GLKMatrix4) getDeviceOrientationMatrix{
    if(_orientToDevice && [motionManager isDeviceMotionActive]){
        CMRotationMatrix a = [[[motionManager deviceMotion] attitude] rotationMatrix];
        // arrangements of mappings of sensor axis to virtual axis (columns)
        // and combinations of 90 degree rotations (rows)
        if(SENSOR_ORIENTATION == 4){
            return GLKMatrix4Make( a.m21,-a.m11, a.m31, 0.0f,
                                   a.m23,-a.m13, a.m33, 0.0f,
                                  -a.m22, a.m12,-a.m32, 0.0f,
                                   0.0f , 0.0f , 0.0f , 1.0f);
        }
        if(SENSOR_ORIENTATION == 3){
            return GLKMatrix4Make(-a.m21, a.m11, a.m31, 0.0f,
                                  -a.m23, a.m13, a.m33, 0.0f,
                                   a.m22,-a.m12,-a.m32, 0.0f,
                                   0.0f , 0.0f , 0.0f , 1.0f);
        }
        if(SENSOR_ORIENTATION == 2){
            return GLKMatrix4Make(-a.m11,-a.m21, a.m31, 0.0f,
                                  -a.m13,-a.m23, a.m33, 0.0f,
                                   a.m12, a.m22,-a.m32, 0.0f,
                                   0.0f , 0.0f , 0.0f , 1.0f);
        }
        return GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                              a.m13, a.m23, a.m33, 0.0f,
                             -a.m12,-a.m22,-a.m32, 0.0f,
                              0.0f , 0.0f , 0.0f , 1.0f);
    }
    else
        return GLKMatrix4Identity;
}
-(void) orientToVector:(GLKVector3)v{
    _attitudeMatrix = GLKMatrix4MakeLookAt(0, 0, 0, v.x, v.y, v.z,  0, 1, 0);
    [self updateLook];
}
-(void) orientToAzimuth:(float)azimuth Altitude:(float)altitude{
    [self orientToVector:GLKVector3Make(-cosf(azimuth), sinf(altitude), sinf(azimuth))];
}
-(void) updateLook{
    _lookVector = GLKVector3Make(-_attitudeMatrix.m02,
                                 -_attitudeMatrix.m12,
                                 -_attitudeMatrix.m22);
    _lookAzimuth = atan2f(_lookVector.x, -_lookVector.z);
    _lookAltitude = asinf(_lookVector.y);
}
-(CGPoint) imagePixelAtScreenLocation:(CGPoint)point{
    return [self imagePixelFromVector:[self vectorFromScreenLocation:point inAttitude:_attitudeMatrix]];
}
-(CGPoint) imagePixelFromVector:(GLKVector3)vector{
    CGPoint pxl = CGPointMake((M_PI-atan2f(-vector.z, -vector.x))/(2*M_PI), acosf(vector.y)/M_PI);
    CGPoint tex = [sphere getTextureSize];
    // if no texture exists, returns between 0.0 - 1.0
    if(!(tex.x == 0.0f && tex.y == 0.0f)){
        pxl.x *= tex.x;
        pxl.y *= tex.y;
    }
    return pxl;
}
-(GLKVector3) vectorFromScreenLocation:(CGPoint)point{
    return [self vectorFromScreenLocation:point inAttitude:_attitudeMatrix];
}
-(GLKVector3) vectorFromScreenLocation:(CGPoint)point inAttitude:(GLKMatrix4)matrix{
    GLKMatrix4 inverse = GLKMatrix4Invert(GLKMatrix4Multiply(_projectionMatrix, matrix), nil);
    GLKVector4 screen = GLKVector4Make(2.0*(point.x/self.frame.size.width-.5),
                                       2.0*(.5-point.y/self.frame.size.height),
                                       1.0, 1.0);
//    if (SENSOR_ORIENTATION == 3 || SENSOR_ORIENTATION == 4)
//        screen = GLKVector4Make(2.0*(screenTouch.x/self.frame.size.height-.5),
//                                2.0*(.5-screenTouch.y/self.frame.size.width),
//                                1.0, 1.0);
    GLKVector4 vec = GLKMatrix4MultiplyVector4(inverse, screen);
    return GLKVector3Normalize(GLKVector3Make(vec.x, vec.y, vec.z));
}
-(CGPoint) screenLocationFromVector:(GLKVector3)vector{
    GLKMatrix4 matrix = GLKMatrix4Multiply(_projectionMatrix, _attitudeMatrix);
    GLKVector3 screenVector = GLKMatrix4MultiplyVector3(matrix, vector);
    return CGPointMake( (screenVector.x/screenVector.z/2.0 + 0.5) * self.frame.size.width,
                       (0.5-screenVector.y/screenVector.z/2) * self.frame.size.height );
}
-(BOOL) computeScreenLocation:(CGPoint*)location fromVector:(GLKVector3)vector inAttitude:(GLKMatrix4)matrix{
//This method returns whether the point is before or behind the screen.
    GLKVector4 screenVector;
    GLKVector4 vector4;
    if(location == NULL)
        return NO;
    matrix = GLKMatrix4Multiply(_projectionMatrix, matrix);
    vector4 = GLKVector4Make(vector.x, vector.y, vector.z, 1);
    screenVector = GLKMatrix4MultiplyVector4(matrix, vector4);
    location->x = (screenVector.x/screenVector.w/2.0 + 0.5) * self.frame.size.width;
    location->y = (0.5-screenVector.y/screenVector.w/2) * self.frame.size.height;
    return (screenVector.z >= 0);
}
#pragma mark- TOUCHES
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _touches = event.allTouches;
    _numberOfTouches = event.allTouches.count;
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    _touches = event.allTouches;
    _numberOfTouches = event.allTouches.count;
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    _touches = event.allTouches;
    _numberOfTouches = 0;
}
-(BOOL)touchInRect:(CGRect)rect{
    if(_numberOfTouches){
        bool found = false;
        for(int i = 0; i < [[_touches allObjects] count]; i++){
            CGPoint touchPoint = CGPointMake([(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].x,
                                             [(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].y);
            found |= CGRectContainsPoint(rect, [self imagePixelAtScreenLocation:touchPoint]);
        }
        return found;
    }
    return false;
}
-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    _numberOfTouches = sender.numberOfTouches;
    static float zoom;
    if([sender state] == 1)
        zoom = _fieldOfView;
    if([sender state] == 2){
        CGFloat newFOV = zoom / [sender scale];
        if(newFOV < FOV_MIN) newFOV = FOV_MIN;
        else if(newFOV > FOV_MAX) newFOV = FOV_MAX;
        [self setFieldOfView:newFOV];
    }
    if([sender state] == 3){
        _numberOfTouches = 0;
    }
}
-(void) panHandler:(UIPanGestureRecognizer*)sender{
    static GLKVector3 touchVector;
    if([sender state] == 1){
        touchVector = [self vectorFromScreenLocation:[sender locationInView:sender.view] inAttitude:_offsetMatrix];
    }
    else if([sender state] == 2){
        GLKVector3 nowVector = [self vectorFromScreenLocation:[sender locationInView:sender.view] inAttitude:_offsetMatrix];
        GLKQuaternion q = GLKQuaternionFromTwoVectors(touchVector, nowVector);
        _offsetMatrix = GLKMatrix4Multiply(_offsetMatrix, GLKMatrix4MakeWithQuaternion(q));
        // in progress for preventHeadTilt
//        GLKMatrix4 mat = GLKMatrix4Multiply(_offsetMatrix, GLKMatrix4MakeWithQuaternion(q));
//        _offsetMatrix = GLKMatrix4MakeLookAt(0, 0, 0, -mat.m02, -mat.m12, -mat.m22,  0, 1, 0);
    }
    else{
        _numberOfTouches = 0;
    }
}
#pragma mark- MERIDIANS
-(void) makeLatitudeLines{
    for(int i = 0; i < 64; i++){
        circlePoints[i*3+0] = -sinf(M_PI*2/64.0f*i);
        circlePoints[i*3+1] = 0.0f;
        circlePoints[i*3+2] = cosf(M_PI*2/64.0f*i);
    }
}
-(void)drawHotspotLines:(GLKVector3)touchLocation{
    glLineWidth(2.0f);
    float scale = sqrtf(1-powf(touchLocation.y,2));
    glPushMatrix();
    glScalef(scale, 1.0f, scale);
    glTranslatef(0, touchLocation.y, 0);
    glDisableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, circlePoints);
    glDrawArrays(GL_LINE_LOOP, 0, 64);
    glDisableClientState(GL_VERTEX_ARRAY);
    glPopMatrix();
    
    glPushMatrix();
    glRotatef(-atan2f(-touchLocation.z, -touchLocation.x)*180/M_PI, 0, 1, 0);
    glRotatef(90, 1, 0, 0);
    glDisableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, circlePoints);
    glDrawArrays(GL_LINE_STRIP, 0, 33);
    glDisableClientState(GL_VERTEX_ARRAY);
    glPopMatrix();
}
@end

@interface Sphere (){
//  from Touch Fighter by Apple
//  in Pro OpenGL ES for iOS
//  by Mike Smithwick Jan 2011 pg. 78
    GLKTextureInfo *m_TextureInfo;
    GLfloat *m_TexCoordsData;
    GLfloat *m_VertexData;
    GLfloat *m_NormalData;
    GLint m_Stacks, m_Slices;
    GLfloat m_Scale;
}
-(GLKTextureInfo *) loadTextureFromBundle:(NSString *) filename;
-(GLKTextureInfo *) loadTextureFromPath:(NSString *) path;
@end
@implementation Sphere
-(id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius textureFile:(NSString *)textureFile{
    // modifications:
    //   flipped(inverted) texture coords across the Z
    //   vertices rotated 90deg
    if(textureFile != nil) m_TextureInfo = [self loadTextureFromBundle:textureFile];
    m_Scale = radius;
    if((self = [super init])){
        m_Stacks = stacks;
        m_Slices = slices;
        m_VertexData = nil;
        m_TexCoordsData = nil;
        // Vertices
        GLfloat *vPtr = m_VertexData = (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));
        // Normals
        GLfloat *nPtr = m_NormalData = (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));
        GLfloat *tPtr = nil;
        tPtr = m_TexCoordsData = (GLfloat*)malloc(sizeof(GLfloat) * 2 * ((m_Slices*2+2) * (m_Stacks)));
        unsigned int phiIdx, thetaIdx;
        // Latitude
        for(phiIdx = 0; phiIdx < m_Stacks; phiIdx++){
            //starts at -pi/2 goes to pi/2
            //the first circle
            float phi0 = M_PI * ((float)(phiIdx+0) * (1.0/(float)(m_Stacks)) - 0.5);
            //second one
            float phi1 = M_PI * ((float)(phiIdx+1) * (1.0/(float)(m_Stacks)) - 0.5);
            float cosPhi0 = cos(phi0);
            float sinPhi0 = sin(phi0);
            float cosPhi1 = cos(phi1);
            float sinPhi1 = sin(phi1);
            float cosTheta, sinTheta;
            //longitude
            for(thetaIdx = 0; thetaIdx < m_Slices; thetaIdx++){
                float theta = -2.0*M_PI * ((float)thetaIdx) * (1.0/(float)(m_Slices - 1));
                cosTheta = cos(theta+M_PI*.5);
                sinTheta = sin(theta+M_PI*.5);
                //get x-y-x of the first vertex of stack
                vPtr[0] = m_Scale*cosPhi0 * cosTheta;
                vPtr[1] = m_Scale*sinPhi0;
                vPtr[2] = m_Scale*(cosPhi0 * sinTheta);
                //the same but for the vertex immediately above the previous one.
                vPtr[3] = m_Scale*cosPhi1 * cosTheta;
                vPtr[4] = m_Scale*sinPhi1;
                vPtr[5] = m_Scale*(cosPhi1 * sinTheta);
                nPtr[0] = cosPhi0 * cosTheta;
                nPtr[1] = sinPhi0;
                nPtr[2] = cosPhi0 * sinTheta;
                nPtr[3] = cosPhi1 * cosTheta;
                nPtr[4] = sinPhi1;
                nPtr[5] = cosPhi1 * sinTheta;
                if(tPtr!=nil){
                    GLfloat texX = (float)thetaIdx * (1.0f/(float)(m_Slices-1));
                    tPtr[0] = 1.0-texX;
                    tPtr[1] = (float)(phiIdx + 0) * (1.0f/(float)(m_Stacks));
                    tPtr[2] = 1.0-texX;
                    tPtr[3] = (float)(phiIdx + 1) * (1.0f/(float)(m_Stacks));
                }
                vPtr += 2*3;
                nPtr += 2*3;
                if(tPtr != nil) tPtr += 2*2;
            }
            //Degenerate triangle to connect stacks and maintain winding order
            vPtr[0] = vPtr[3] = vPtr[-3];
            vPtr[1] = vPtr[4] = vPtr[-2];
            vPtr[2] = vPtr[5] = vPtr[-1];
            nPtr[0] = nPtr[3] = nPtr[-3];
            nPtr[1] = nPtr[4] = nPtr[-2];
            nPtr[2] = nPtr[5] = nPtr[-1];
            if(tPtr != nil){
                tPtr[0] = tPtr[2] = tPtr[-2];
                tPtr[1] = tPtr[3] = tPtr[-1];
            }
        }
    }
    return self;
}
-(bool) execute{
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    if(m_TexCoordsData != nil){
        glEnable(GL_TEXTURE_2D);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        if(m_TextureInfo != 0)
            glBindTexture(GL_TEXTURE_2D, m_TextureInfo.name);
        glTexCoordPointer(2, GL_FLOAT, 0, m_TexCoordsData);
    }
    glVertexPointer(3, GL_FLOAT, 0, m_VertexData);
    glNormalPointer(GL_FLOAT, 0, m_NormalData);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (m_Slices +1) * 2 * (m_Stacks-1)+2);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    return true;
}
-(GLKTextureInfo *) loadTextureFromBundle:(NSString *) filename{
    if(!filename) return nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:NULL];
    return [self loadTextureFromPath:path];
}
-(GLKTextureInfo *) loadTextureFromPath:(NSString *) path{
    if(!path) return nil;
    NSError *error;
    GLKTextureInfo *info;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    info=[GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    glBindTexture(GL_TEXTURE_2D, info.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, IMAGE_SCALING);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, IMAGE_SCALING);
    return info;
}
-(void)swapTexture:(NSString*)textureFile{
    GLuint name = m_TextureInfo.name;
    glDeleteTextures(1, &name);
    if ([[NSFileManager defaultManager] fileExistsAtPath:textureFile]) {
        m_TextureInfo = [self loadTextureFromPath:textureFile];
    }
    else {
        m_TextureInfo = [self loadTextureFromBundle:textureFile];
    }
}
-(CGPoint)getTextureSize{
    if(m_TextureInfo){
        return CGPointMake(m_TextureInfo.width, m_TextureInfo.height);
    }
    else{
        return CGPointZero;
    }
}

@end