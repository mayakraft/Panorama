//
//  GLController.m
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "GLController.h"
#import "gluLookAt.h"

@implementation GLController

-(id) init{
    [self initGeometry];
    m_CelestialSphere = [[Sphere alloc] init:50 slices:50 radius:1.0 squash:1.0 textureFile:@"park.jpg"];
    [m_CelestialSphere setPositionX:0.0 Y:0.0 Z:0.0];
    return self;
}
-(id) initWithTexture:(NSString*)fileName{
    [self initGeometry];
    m_CelestialSphere = [[Sphere alloc] init:50 slices:50 radius:1.0 squash:1.0 textureFile:fileName];
    [m_CelestialSphere setPositionX:0.0 Y:0.0 Z:0.0];
    return self;
}

-(void)initGeometry{
    m_Eyeposition[X_VALUE] = 0.0;
    m_Eyeposition[Y_VALUE] = 0.0;
    m_Eyeposition[Z_VALUE] = 0.0;
    
    m_Eyerotation[X_VALUE] = 0.0;
    m_Eyerotation[Y_VALUE] = 0.0;
    m_Eyerotation[Z_VALUE] = 0.0;
}

-(void)execute
{
    [self interpolateEye];
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    GLfloat black[] = {0.0,0.0,0.0,0.0};
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    
    double yawrad = (M_PI*m_Eyerotation[Y_VALUE])/180;
    double pitchrad = (M_PI*m_Eyerotation[X_VALUE])/180;
    double rollrad = M_PI*m_Eyerotation[Z_VALUE]/180;
    
    double tanpitchrad;
    if(pitchrad>M_PI*2)
        pitchrad-=M_PI*2;
    if(pitchrad<0)
        pitchrad+=M_PI*2;
    if(pitchrad > M_PI*.5 && pitchrad < M_PI*3/2.0){
        tanpitchrad = tanf(pitchrad);
        yawrad -= M_PI;
        switchFlag = true;
    }
    else{
        tanpitchrad = -tanf(pitchrad);
        switchFlag = false;
    }
    //NSLog(@"%.3f",pitchrad);
    eyeMatrix = GLKMatrix4MakeLookAt(m_Eyeposition[X_VALUE], m_Eyeposition[Y_VALUE], m_Eyeposition[Z_VALUE],
                                     -sinf(yawrad), tanpitchrad, cosf(yawrad),
                                     cosf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ),cosf(rollrad)*1/cosf(pitchrad), sinf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ) );
    
    
    gluLookAt(m_Eyeposition[X_VALUE], m_Eyeposition[Y_VALUE], m_Eyeposition[Z_VALUE],
              -sinf(yawrad), tanpitchrad, cosf(yawrad),
              cosf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ),cosf(rollrad)*1/cosf(pitchrad), sinf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ) );
    
    //              -sinf(rollrad),cosf(rollrad)*1/cosf(pitchrad),0);   // FIRST moment I was doing this right, only rolls if pointed along the +x axis instead of the z, or -x.
    //              -sinf(rollrad),-1*((switchFlag*2)-1)*cosf(rollrad),0);
    //              sinf(rollrad)*sinf(yawrad),1*cosf(rollrad),sinf(rollrad)*cosf(yawrad));
    //              -sinf(rollrad)*sinf(pitchrad), cosf(rollrad), -sinf(rollrad)*cosf(pitchrad));
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glTranslatef(-m_Eyeposition[X_VALUE], -m_Eyeposition[Y_VALUE], -m_Eyeposition[Z_VALUE]);
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    
    //    glRotatef(m_Eyerotation[Z_VALUE], 0.0, 0.0, 1.0);
    //    glRotatef(m_Eyerotation[X_VALUE], 1.0, 0.0, 0.0);
    //    glRotatef(m_Eyerotation[Y_VALUE], 0.0, 1.0, 0.0);
    
    [self executeSphere:m_CelestialSphere];
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
    glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    
}

-(void) report{
    //    NSLog(@"[%.3f  %.3f  %.3f  %.3f]",eyeMatrix.m00, eyeMatrix.m01, eyeMatrix.m02, eyeMatrix.m03);
    //    NSLog(@"[%.3f  %.3f  %.3f  %.3f]",eyeMatrix.m10, eyeMatrix.m11, eyeMatrix.m12, eyeMatrix.m13);
    //    NSLog(@"[%.3f  %.3f  %.3f  %.3f]",eyeMatrix.m20, eyeMatrix.m21, eyeMatrix.m22, eyeMatrix.m23);
    //    NSLog(@"[%.3f  %.3f  %.3f  %.3f]",eyeMatrix.m30, eyeMatrix.m31, eyeMatrix.m32, eyeMatrix.m33);
    
    NSLog(@"%d [%.3f  %.3f  %.3f  %.3f]",switchFlag,eyeMatrix.m00, eyeMatrix.m10, eyeMatrix.m20, eyeMatrix.m30);
    NSLog(@"%d [%.3f  %.3f  %.3f  %.3f]",switchFlag,eyeMatrix.m01, eyeMatrix.m11, eyeMatrix.m21, eyeMatrix.m31);
    NSLog(@"%d [%.3f  %.3f  %.3f  %.3f]",switchFlag,eyeMatrix.m02, eyeMatrix.m12, eyeMatrix.m22, eyeMatrix.m32);
    NSLog(@"%d [%.3f  %.3f  %.3f  %.3f]",switchFlag,eyeMatrix.m03, eyeMatrix.m13, eyeMatrix.m23, eyeMatrix.m33);
    
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

-(void) setEyeX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    m_Eyeposition[X_VALUE] = x;
    m_Eyeposition[Y_VALUE] = y;
    m_Eyeposition[Z_VALUE] = z;
}

-(void) setEyeRotationX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
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