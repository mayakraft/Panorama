//
//  PanoramaView.m
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "PanoramaView.h"
#import "gluLookAt.h"
#import "Sphere.h"

#define X_VALUE     0
#define Y_VALUE     1
#define Z_VALUE     2

@interface PanoramaView (){
    Sphere *m_CelestialSphere;
    GLfloat m_Eyerotation[3];
    GLfloat m_EyeInterpolationVector[3];
    CGFloat aspectRatio;
    CMMotionManager *motionManager;
    NSInteger clock;
}
@end

@implementation PanoramaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        [EAGLContext setCurrentContext:context];
        self.context = context;
        [self initGeometry];
    }
    return self;
}
-(id) init{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}

-(id) initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    return [self initWithFrame:frame];
}

-(void) setTexture:(NSString*)fileName{
    m_CelestialSphere = [[Sphere alloc] init:25 slices:25 radius:1.0 squash:1.0 textureFile:fileName];
    [m_CelestialSphere setPositionX:0.0 Y:0.0 Z:0.0];
}

-(void)initGeometry{
    // init lighting
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    glEnable(GL_LIGHTING);
    
    _FOV = 90;
    m_Eyerotation[X_VALUE] = 0.0;
    m_Eyerotation[Y_VALUE] = 0.0;
    m_Eyerotation[Z_VALUE] = 0.0;

    glMatrixMode(GL_PROJECTION);    // the frustum affects the projection matrix
    glLoadIdentity();               // not the model matrix
    aspectRatio = (float)[[UIScreen mainScreen] bounds].size.height / (float)[[UIScreen mainScreen] bounds].size.width;
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(_FOV) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

-(void)setFOV:(float)fov{
    _FOV = fov;
    [self updateFieldOfView];
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

-(void) beginUpdates{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.0/15.0;
    if(motionManager.isDeviceMotionAvailable){
        [motionManager startDeviceMotionUpdates];
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *deviceMotion, NSError *error){
            CMAttitude *attitude = deviceMotion.attitude;
            [self setEyeRotationX:(attitude.roll+M_PI/2.0)*180/M_PI Y:(-attitude.yaw)*180/M_PI Z:attitude.pitch*180/M_PI];
            if(clock % 15 == 0)
                NSLog(@"(P:%.2f, R:%.2f, Y:%.2f)",(attitude.roll+M_PI/2.0)*180/M_PI, attitude.pitch*180/M_PI, (-attitude.yaw)*180/M_PI);
            clock++;
        }];
    }
}

-(void) swapTexture:(NSString*)fileName{
    [m_CelestialSphere swapTexture:fileName];
}

-(void)execute
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self interpolateEye];
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    GLfloat black[] = {0.0,0.0,0.0,0.0};
    
    double yawrad = (M_PI*m_Eyerotation[Y_VALUE])/180.0;
    double pitchrad = (M_PI*m_Eyerotation[X_VALUE])/180.0;
    double rollrad = M_PI*m_Eyerotation[Z_VALUE]/180.0;
    
    double tanpitchrad;
    if(pitchrad>M_PI*2)
        pitchrad-=M_PI*2;
    if(pitchrad<0)
        pitchrad+=M_PI*2;
    if(pitchrad > M_PI*.5 && pitchrad < M_PI*3/2.0){
        tanpitchrad = tanf(pitchrad);
        yawrad -= M_PI;
    }
    else
        tanpitchrad = -tanf(pitchrad);
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    gluLookAt(0.0, 0.0, 0.0, -sinf(yawrad), tanpitchrad, cosf(yawrad),
              cosf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ),cosf(rollrad)*1/cosf(pitchrad), sinf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ) );
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    [self executeSphere:m_CelestialSphere];
    glPopMatrix();
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
}

-(void)executeSphere:(Sphere *)sphere
{
    GLfloat posX, posY, posZ;
    glPushMatrix();
    [sphere getPositionX:&posX Y:&posY Z:&posZ];
    glTranslatef(posX, posY, posZ);
    [sphere execute];
    glPopMatrix();
}
-(void) buildEyeInterpolationVectorFromNewX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    m_EyeInterpolationVector[X_VALUE] = (m_Eyerotation[X_VALUE]-x);
    m_EyeInterpolationVector[Y_VALUE] = (m_Eyerotation[Y_VALUE]-y);
    m_EyeInterpolationVector[Z_VALUE] = (m_Eyerotation[Z_VALUE]-z);
}

-(void) setEyeRotationX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    if((m_Eyerotation[Y_VALUE] > 90 && y < -90) )
        m_Eyerotation[Y_VALUE] -= 360;
    else if((m_Eyerotation[Y_VALUE] < -90 && y > 90) )
        m_Eyerotation[Y_VALUE] += 360;
    
    if((m_Eyerotation[X_VALUE] > 180 && x < 0) )
        m_Eyerotation[X_VALUE] -= 360;
    else if((m_Eyerotation[X_VALUE] < 0 && x > 180) )
        m_Eyerotation[X_VALUE] += 360;
    
    m_EyeInterpolationVector[X_VALUE] = (x-m_Eyerotation[X_VALUE])/2.0;
    m_EyeInterpolationVector[Y_VALUE] = (y-m_Eyerotation[Y_VALUE])/2.0;
    m_EyeInterpolationVector[Z_VALUE] = (z-m_Eyerotation[Z_VALUE])/2.0;
}
-(void)interpolateEye
{
    m_Eyerotation[X_VALUE] += m_EyeInterpolationVector[X_VALUE];
    m_Eyerotation[Y_VALUE] += m_EyeInterpolationVector[Y_VALUE];
    m_Eyerotation[Z_VALUE] += m_EyeInterpolationVector[Z_VALUE];
}

@end