//
//  PanoramaView.m
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//  MIT license
//

#import <CoreMotion/CoreMotion.h>
#import "PanoramaView.h"
#import "Sphere.h"

#define FOV_MIN 1
#define FOV_MAX 155
#define Z_NEAR 0.1f
#define Z_FAR 100.0f

@interface PanoramaView (){
    Sphere *sphere;
    GLKMatrix4 _attitudeMatrix, _projectionMatrix;
    float _aspectRatio;
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
//    UIPanGestureRecognizer *panGesture;
//    float panX, panY;  // for manual panning
    GLfloat circlePoints[64*3];  // hotspot lines
}
@end

@implementation PanoramaView

-(id) init{
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
    }
    return self;
}
-(void) initDevice{
    motionManager = [[CMMotionManager alloc] init];
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [pinchGesture setEnabled:NO];
    [self addGestureRecognizer:pinchGesture];
//    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
//    [self addGestureRecognizer:panGesture];
}
-(void)setFieldOfView:(float)fieldOfView{
    _fieldOfView = fieldOfView;
    [self rebuildProjectionMatrix];
}
-(void) setImage:(NSString*)fileName{
    [sphere swapTexture:fileName];
}
-(void) setPinchToZoom:(BOOL)pinchToZoom{
    _pinchToZoom = pinchToZoom;
    if(_pinchToZoom)
        [pinchGesture setEnabled:YES];
    else
        [pinchGesture setEnabled:NO];
}
-(void) setOrientToDevice:(BOOL)orientToDevice{
    _orientToDevice = orientToDevice;
    if(_orientToDevice){
        if(motionManager.isDeviceMotionAvailable)
            [motionManager startDeviceMotionUpdates];
//        [panGesture setEnabled:NO];  // disable panning if using accelerometer/gyro
    }
    else {
        if(motionManager.isDeviceMotionAvailable)
            [motionManager stopDeviceMotionUpdates];
//        [panGesture setEnabled:YES];
//        panX = panY = 0.0f;
    }
}
#pragma mark- OPENGL
-(void)initOpenGL:(EAGLContext*)context{
    [(CAEAGLLayer*)self.layer setOpaque:YES];
    float width, height;
    if([UIApplication sharedApplication].statusBarOrientation > 2){
        width = [[UIScreen mainScreen] bounds].size.height;
        height = [[UIScreen mainScreen] bounds].size.width;
    } else{
        width = [[UIScreen mainScreen] bounds].size.width;
        height = [[UIScreen mainScreen] bounds].size.height;
    }
    _aspectRatio = width/height;
    _fieldOfView = 60;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) _fieldOfView = 75;
    [self rebuildProjectionMatrix];
    [self customGL];
    
    // hotspot lines
    [self initCirclePoints];
}
-(void)rebuildProjectionMatrix{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat frustum = Z_NEAR * tanf(_fieldOfView*0.00872664625997);  // pi/180/2
    _projectionMatrix = GLKMatrix4MakeFrustum(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    glMultMatrixf(_projectionMatrix.m);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    glMatrixMode(GL_MODELVIEW);
}
-(void) customGL{
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}
-(void)draw{
    static GLfloat whiteColor[] = {1.0f, 1.0f, 1.0f, 1.0f};
    static GLfloat clearColor[] = {0.0f, 0.0f, 0.0f, 0.0f};
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glPushMatrix(); // begin device orientation
    
        if(_orientToDevice){
            _attitudeMatrix = [self getDeviceOrientationMatrix];
            glMultMatrixf(_attitudeMatrix.m);
        }
        else{
            glScalef(1, 1, -1);
//            _attitudeMatrix = [self buildOrientationMatrixAz:panY Alt:panX];
//            glRotatef(panY/5., 1, 0, 0);
//            glRotatef(panX/5., 0, 1, 0);
        }
        [self updateLook];
    
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, whiteColor);  // panorama display at full color
        [sphere execute];
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, clearColor);

//TODO: add objects here to make them a part of the virtual reality
//        glPushMatrix();
//        // object code
//        glPopMatrix();
    
        // hotspot lines
        if(_showTouches && _numberOfTouches){
            glColor4f(1.0f, 1.0f, 1.0f, 0.75f);
            for(int i = 0; i < [[_touches allObjects] count]; i++){
                glPushMatrix();
                    CGPoint touchPoint = CGPointMake([(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].x,
                                                     [(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].y);
                    [self drawHotspotLines:[self vectorFromScreenLocation:touchPoint]];
                glPopMatrix();
            }
            glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
        }
    
    glPopMatrix(); // end device orientation
}
#pragma mark- ORIENTATION
-(GLKMatrix4) getDeviceOrientationMatrix{
    if([motionManager isDeviceMotionActive]){
        CMRotationMatrix a = [[[motionManager deviceMotion] attitude] rotationMatrix];
        return GLKMatrix4Make(-a.m12,-a.m22,-a.m32,0.0f,  // two built-in 90 rotations
                              a.m13, a.m23, a.m33, 0.0f,  // and reflection across
                              a.m11, a.m21, a.m31, 0.0f,  // z axis to invert texture
                              0.0f , 0.0f , 0.0f , 1.0f);
    }
    else return GLKMatrix4Identity;
}
-(void) updateLook{
    _lookVector = GLKVector3Make(-_attitudeMatrix.m02,
                                 -_attitudeMatrix.m12,
                                 -_attitudeMatrix.m22);
    _lookAzimuth = -atan2f(-_lookVector.z, -_lookVector.x);
    _lookAltitude = asinf(_lookVector.y);
}
-(CGPoint) imagePixelFromScreenLocation:(CGPoint)point{
    return [self imagePixelFromVector:[self vectorFromScreenLocation:point]];
}
-(GLKVector3) vectorFromScreenLocation:(CGPoint)screenTouch{
    GLKMatrix4 inverse = GLKMatrix4Invert(GLKMatrix4Multiply(_projectionMatrix, _attitudeMatrix), nil);
    GLKVector4 screen = GLKVector4Make(2.0*(screenTouch.x/[[UIScreen mainScreen] bounds].size.width-.5),
                                       2.0*(.5-screenTouch.y/[[UIScreen mainScreen] bounds].size.height),
                                       1.0, 1.0);
    GLKVector4 vec = GLKMatrix4MultiplyVector4(inverse, screen);
    return GLKVector3Normalize(GLKVector3Make(vec.x, vec.y, vec.z));
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
//-(void) panHandler:(UIPanGestureRecognizer*)sender{
//    static float startX, startY;
//    if([sender state] == 1){
//        startX = panX;
//        startY = panY;
//    }
//    else if([sender state] == 2){
//        panX = startX + [sender translationInView:sender.view].x;
//        panY = startY + [sender translationInView:sender.view].y;
//    }
//    else{
//        numberOfTouches = 0;
//    }
//}
#pragma mark- HOTSPOT
-(void) initCirclePoints{
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