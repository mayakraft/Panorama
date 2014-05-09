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
    UIPanGestureRecognizer *panGesture;
    float panAzimuth, panAltitude;  // for manual panning
    GLKVector3 panVector;
    GLfloat circlePoints[64*3];  // hotspot lines
    bool _deviceLandscape;  //TODO: expand. presently only works for device orientation Portrait and Landscape Left
}
@end

@implementation PanoramaView

-(id) init{
    CGRect frame = [[UIScreen mainScreen] bounds];
    if([[UIApplication sharedApplication] statusBarOrientation] > 2){
        return [self initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width)];
    } else{
        return [self initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    }
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
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:panGesture];
    panVector.x = -1;
    panVector.y = 0;
    panVector.z = 0;
    _attitudeMatrix = [self buildOrientationMatrixAz:0 Alt:0];
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
        [panGesture setEnabled:NO];  // disable panning if using accelerometer/gyro
    }
    else {
        if(motionManager.isDeviceMotionAvailable)
            [motionManager stopDeviceMotionUpdates];
        [panGesture setEnabled:YES];
        panAzimuth = _lookAzimuth;
        panAltitude = _lookAltitude;
        panVector.x = -1;
        panVector.y = 0;
        panVector.z = 0;
    }
}
#pragma mark- OPENGL
-(void)initOpenGL:(EAGLContext*)context{
    [(CAEAGLLayer*)self.layer setOpaque:YES];
    if([[UIApplication sharedApplication] statusBarOrientation] > 2){
        _deviceLandscape = true;
        _fieldOfView = 105;
    } else{
        _deviceLandscape = false;
        _fieldOfView = 60;
    }
    _aspectRatio = self.frame.size.width/self.frame.size.height;
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
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
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
        }
        //else, _attitudeMatrix should get updates in a gesture handler

        [self updateLook];
    
        glMultMatrixf(_attitudeMatrix.m);
    
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, whiteColor);  // panorama at full color
        [sphere execute];
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, clearColor);

//TODO: add objects here to make them a part of the virtual reality
//        glPushMatrix();
//        // object code
//        glPopMatrix();
    
        // hotspot lines
        if(_showTouches && _numberOfTouches){
            glColor4f(1.0f, 1.0f, 1.0f, 0.5f);
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
        if(_deviceLandscape){
            return GLKMatrix4Make(-a.m22, a.m12,-a.m32, 0.0f,
                                   a.m23,-a.m13, a.m33, 0.0f,
                                   a.m21,-a.m11, a.m31, 0.0f,
                                   0.0f , 0.0f , 0.0f , 1.0f);
        }
        return GLKMatrix4Make(-a.m12,-a.m22,-a.m32, 0.0f,  // two built-in 90 rotations
                               a.m13, a.m23, a.m33, 0.0f,  // and reflection across
                               a.m11, a.m21, a.m31, 0.0f,  // z axis to invert texture
                               0.0f , 0.0f , 0.0f , 1.0f);
    }
    else
        return GLKMatrix4Identity;
}
-(GLKMatrix4) buildOrientationMatrixAz:(float)azimuth Alt:(float)altitude{
    GLKMatrix4 r = GLKMatrix4Identity;
//    r = GLKMatrix4Rotate(r, 180, panVector.x, panVector.y, panVector.z);

    GLKMatrix4 r2 = GLKMatrix4MakeLookAt(0, 0, 0, panVector.x, panVector.y, panVector.z, 0, 1, 0);
    
    r = GLKMatrix4Scale(r2, 1, 1, -1);

//    r = GLKMatrix4Rotate(r, -altitude, 1, 0, 0);
//    r = GLKMatrix4Rotate(r, azimuth, 0, 1, 0);   // would be negative but we reflected across the z axis
//    r = GLKMatrix4Rotate(r, M_PI*.5, 0, 1, 0);  // always a 90 y-axis to align the beginning to the center of image
    
//    GLKMatrix4MultiplyVector3(r, panVector);
//    r = GLKMatrix4Rotate(r, altitude/180., 1, 0, 0);
//    r = GLKMatrix4Rotate(r, azimuth/180., 0, 1, 0);
    return r;
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
    GLKVector4 screen = GLKVector4Make(2.0*(screenTouch.x/self.frame.size.width-.5),
                                       2.0*(.5-screenTouch.y/self.frame.size.height),
                                       1.0, 1.0);
    if (_deviceLandscape) screen = GLKVector4Make(2.0*(screenTouch.x/self.frame.size.height-.5),
                                                  2.0*(.5-screenTouch.y/self.frame.size.width),
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
// basically re-programming our own PanGesture at this point
-(void) panHandler:(UIPanGestureRecognizer*)sender{
    static float startAz, startAlt, touchAz, touchAlt;
    static float translationAz, translationAlt;  // translationInView
    if([sender state] == 1){
        startAz = panAzimuth;
        startAlt = panAltitude;
        // this will never change since the world will be moving with the finger
        GLKVector3 touchVector = [self vectorFromScreenLocation:[sender locationInView:sender.view]];
        touchAz = -atan2f(-touchVector.z, -touchVector.x);
        touchAlt = asinf(touchVector.y);
        translationAz = translationAlt = 0.0;
    }
    else if([sender state] == 2){
        GLKVector3 nowVector = [self vectorFromScreenLocation:[sender locationInView:sender.view]];
        panVector = nowVector;
        float nowAz = -atan2f(-nowVector.z, -nowVector.x);
        float nowAlt = asinf(nowVector.y);
        // nowVector should be ahead of touchVector by a tiny bit
        float stepAz = nowAz - touchAz;
        float stepAlt = nowAlt - touchAlt;
        
        translationAz += stepAz;
        translationAlt += stepAlt;
        panAzimuth  =  startAz + translationAz;
        panAltitude = startAlt + translationAlt;
//        NSLog(@"NOW:   AZ:%.3f  ALT:%.3f", nowAz, nowAlt);
//        NSLog(@"STEP:  AZ:%.3f  ALT:%.3f", stepAz, stepAlt);
//        NSLog(@"    =  AZ:%.3f  ALT:%.3f", panAzimuth, panAltitude);
    }
    else{
        _numberOfTouches = 0;
    }
    _attitudeMatrix = [self buildOrientationMatrixAz:panAzimuth Alt:panAltitude];
}
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