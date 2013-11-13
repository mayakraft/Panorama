//
//  PanoramaView.m
//  Spherical
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
    CGFloat _aspectRatio;
    GLKVector3 _eyeVector;  // forward direction
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
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
        sphere = [[Sphere alloc] init:SLICES slices:SLICES radius:1.0 squash:1.0 textureFile:nil];
    }
    return self;
}

-(void) initDevice{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.0/45.0;
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [pinchGesture setEnabled:NO];
    [self addGestureRecognizer:pinchGesture];
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

-(void) setOrientToDevice:(BOOL)orientToDevice{
    _orientToDevice = orientToDevice;
    if(_orientToDevice){
        if(motionManager.isDeviceMotionAvailable){
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                _attitudeMatrix =
                GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                               a.m13, a.m23, a.m33, 0.0f,
                               -a.m12,-a.m22,-a.m32,0.0f,
                               0.0f , 0.0f , 0.0f , 1.0f);
                _eyeVector = GLKVector3Make(_attitudeMatrix.m02,
                                            _attitudeMatrix.m12,
                                            _attitudeMatrix.m22);
            }];
        }
    }
    else {
        [motionManager stopDeviceMotionUpdates];
    }
}

-(void)execute{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    glMatrixMode(GL_MODELVIEW);
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    glPushMatrix();
        glMultMatrixf(_attitudeMatrix.m);
        [sphere execute];
    glPopMatrix();
}

@end