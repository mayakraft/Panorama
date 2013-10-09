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

-(id) initWithTexture:(NSString*)fileName{
    [self initGeometry];
    m_CelestialSphere = [[Sphere alloc] init:50 slices:50 radius:1.0 squash:1.0 textureFile:fileName];
    [m_CelestialSphere setPositionX:0.0 Y:0.0 Z:0.0];
    return self;
}
-(id) init{
    return [self initWithTexture:@"park_2048.png"];
}

-(void) swapTexture:(NSString*)textureFile{
    NSLog(@"Now Entering %@",textureFile);
    [m_CelestialSphere swapTexture:textureFile];
}

-(void)initGeometry{
    m_Eyerotation[X_VALUE] = 0.0;
    m_Eyerotation[Y_VALUE] = 0.0;
    m_Eyerotation[Z_VALUE] = 0.0;
}

-(void)execute
{
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