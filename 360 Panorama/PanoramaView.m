//
//  PanoramaView.m
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "PanoramaView.h"
#import "Sphere.h"

@interface PanoramaView (){
    Sphere *m_CelestialSphere;
    CGFloat aspectRatio;
    CMMotionManager *motionManager;
}
@end

@implementation PanoramaView

-(id) init{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}
-(id) initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    return [self initWithFrame:frame];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        motionManager = [[CMMotionManager alloc] init];
        motionManager.deviceMotionUpdateInterval = 1.0/30.0;
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        [EAGLContext setCurrentContext:context];
        self.context = context;
        [self initGeometry];
    }
    return self;
}

-(void)initGeometry{
    _FOV = 90;    
    _deviceMotionAttitudeMatrix = GLKMatrix4MakeRotation(-M_PI_2, 1.0f, 0.0f, 0.0f);
    aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    if([UIApplication sharedApplication].statusBarOrientation > 2)
        aspectRatio = 1/aspectRatio;

    // init lighting
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    glEnable(GL_LIGHTING);
    glMatrixMode(GL_PROJECTION);    // the frustum affects the projection matrix
    glLoadIdentity();               // not the model matrix
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(_FOV) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

-(void) updateFieldOfView{
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(_FOV) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
}

-(void) setTexture:(NSString*)fileName{
    m_CelestialSphere = [[Sphere alloc] init:15 slices:15 radius:1.0 squash:1.0 textureFile:fileName];
    [m_CelestialSphere setPositionX:0.0 Y:0.0 Z:0.0];
}

-(void) swapTexture:(NSString*)fileName{
    [m_CelestialSphere swapTexture:fileName];
}

-(void)setFOV:(float)fov{
    _FOV = fov;
    [self updateFieldOfView];
}

-(void) setHardwareOrientationActive:(BOOL)hardwareOrientationActive{
    _hardwareOrientationActive = hardwareOrientationActive;
    if(hardwareOrientationActive){
        if(motionManager.isDeviceMotionAvailable){
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *deviceMotion, NSError *error){
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                _deviceMotionAttitudeMatrix =
                GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                               a.m12, a.m22, a.m32, 0.0f,
                               a.m13, a.m23, a.m33, 0.0f,
                               0.0f, 0.0f, 0.0f, 1.0f);
                GLKMatrix4 rotate = GLKMatrix4MakeRotation(M_PI/2, 1, 0, 0);
                _deviceMotionAttitudeMatrix = GLKMatrix4Multiply(_deviceMotionAttitudeMatrix, rotate);
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
    GLfloat black[] = {0.0,0.0,0.0,0.0};
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glMultMatrixf(_deviceMotionAttitudeMatrix.m);
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    [self executeSphere:m_CelestialSphere];
    glPopMatrix();
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
}

-(void)executeSphere:(Sphere *)sphere{
    GLfloat posX, posY, posZ;
    glPushMatrix();
    [sphere getPositionX:&posX Y:&posY Z:&posZ];
    glTranslatef(posX, posY, posZ);
    [sphere execute];
    glPopMatrix();
}

@end