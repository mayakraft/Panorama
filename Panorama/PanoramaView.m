//
//  PanoramaView.m
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "PanoramaView.h"
#import "Sphere.h"

#define Z_NEAR 0.1f
#define Z_FAR 10.0f
#define FOV_MIN 1
#define FOV_MAX 155
#define SLICES 48  // curvature of projection sphere
#define REFRESH 45.0f  // refresh rate, per second

@interface PanoramaView (){
    Sphere *sphere;
    float _aspectRatio;
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
    UIPanGestureRecognizer *panGesture;
    float panX, panY;
}
@end

@implementation PanoramaView

-(id) init{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}
-(id) initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    return [self initWithFrame:frame];
}
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDevice];
        [self initGL];
        sphere = [[Sphere alloc] init:SLICES slices:SLICES radius:1.0 textureFile:nil];
    }
    return self;
}

-(void) initDevice{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.0/45.0;
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [pinchGesture setEnabled:NO];
    [self addGestureRecognizer:pinchGesture];
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [panGesture setEnabled:NO];
    [self addGestureRecognizer:panGesture];
}

-(void)initGL{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) _fieldOfView = 75;
    else _fieldOfView = 60;
    _aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    // correct if in landscape orientation
    if([UIApplication sharedApplication].statusBarOrientation > 2)
        _aspectRatio = 1/_aspectRatio;
    
    // init lighting
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    glEnable(GL_LIGHTING);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    [self setFieldOfView:_fieldOfView];
    glEnable(GL_DEPTH_TEST);
    glLoadIdentity();
}

-(void)setFieldOfView:(float)fieldOfView{
    _fieldOfView = fieldOfView;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat frustum = Z_NEAR * tanf(GLKMathDegreesToRadians(_fieldOfView) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    glMatrixMode(GL_MODELVIEW);
}

-(void) setTexture:(NSString*)fileName{
    [sphere swapTexture:fileName];
}

-(void) setPinchZoom:(BOOL)pinchZoom{
    _pinchZoom = pinchZoom;
    if(_pinchZoom)
        [pinchGesture setEnabled:YES];
    else
        [pinchGesture setEnabled:NO];
}

-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    static float zoom;
    if([sender state] == 1)
        zoom = _fieldOfView;
    if([sender state] == 2){
        CGFloat newFOV = zoom / [sender scale];
        if(newFOV < FOV_MIN) newFOV = FOV_MIN;
        else if(newFOV > FOV_MAX) newFOV = FOV_MAX;
        [self setFieldOfView:newFOV];
    }
}

-(void) panHandler:(UIPanGestureRecognizer*)sender{
    static float startX, startY;
    if([sender state] == 1){
        startX = panX;
        startY = panY;
    }
    else if([sender state] == 2){
        panX = startX + [sender translationInView:sender.view].x;
        panY = startY + [sender translationInView:sender.view].y;
    }
}

-(void) setOrientToDevice:(BOOL)orientToDevice{
    _orientToDevice = orientToDevice;
    if(_orientToDevice){
        [panGesture setEnabled:NO];  // disable panning if using accelerometer/gyro
        if(motionManager.isDeviceMotionAvailable){
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                // matrix has a built-in 90 rotation, and reflection across the X to correct the inverted texture
                _attitudeMatrix =
                GLKMatrix4Make(-a.m11,-a.m21,-a.m31, 0.0f,
                                a.m13, a.m23, a.m33, 0.0f,
                               -a.m12,-a.m22,-a.m32, 0.0f,
                                0.0f , 0.0f , 0.0f , 1.0f);
                _lookVector = GLKVector3Make(_attitudeMatrix.m02, // if not for texture correction, this would be negative
                                             -_attitudeMatrix.m12,
                                             -_attitudeMatrix.m22);
                _lookAzimuth = atan2f(_lookVector.z, _lookVector.x);
                _lookAltitude = asinf(_lookVector.y);
            }];
        }
    }
    else {
        [motionManager stopDeviceMotionUpdates];
        [panGesture setEnabled:YES];
        panX = panY = 0.0f;
    }
}

-(void)execute{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    glMatrixMode(GL_MODELVIEW);
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    glPushMatrix();
    if(_orientToDevice)
        glMultMatrixf(_attitudeMatrix.m);
    else{
        glRotatef(panY/5., -1, 0, 0);
        glRotatef(panX/5., 0, -1, 0);
    }
    [sphere execute];
    glPopMatrix();
    
//    [self logSensorOrientation];
}

-(void)logSensorOrientation{
    static int timeIndex;
    timeIndex++;
    if(timeIndex % 10 == 0)
        NSLog(@"\n[ %.3f, %.3f, %.3f ]\n[ %.3f, %.3f, %.3f ]\n[ %.3f, %.3f, %.3f ]\n--(%.3f, %.3f, %.3f)--\n--(AZ:%.3f  ALT:%.3f)--",
              _attitudeMatrix.m00, _attitudeMatrix.m01, _attitudeMatrix.m02,
              _attitudeMatrix.m10, _attitudeMatrix.m11, _attitudeMatrix.m12,
              _attitudeMatrix.m20, _attitudeMatrix.m21, _attitudeMatrix.m22,
              _lookVector.x, _lookVector.y, _lookVector.z,
              _lookAzimuth, _lookAltitude);
}

@end