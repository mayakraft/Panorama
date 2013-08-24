//
//  GLController.h
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Sphere.h"

#define X_VALUE     0
#define Y_VALUE     1
#define Z_VALUE     2

@interface GLController : NSObject{
    Sphere *m_CelestialSphere;
    GLfloat m_Eyeposition[3];
    GLfloat m_Eyerotation[3];
    GLfloat m_EyeInterpolationVector[3];
    
    GLKMatrix4 eyeMatrix;
    BOOL switchFlag;
}

-(void)execute;
-(id) init;
-(id) initWithTexture:(NSString*)fileName;
-(void) setEyeX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
-(void) setEyeRotationX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
-(void) buildEyeInterpolationVectorFromNewX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;

-(void) report;

@end
