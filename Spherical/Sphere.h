//
//  Sphere.h
//  Spherical
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <GLKit/GLKit.h>

@interface Sphere : NSObject
{
@private
    GLKTextureInfo *m_TextureInfo;
    GLfloat *m_TexCoordsData;
    GLfloat *m_VertexData;
    GLfloat *m_NormalData;
    GLubyte *m_ColorData;
    
    GLint m_Stacks, m_Slices;
    GLfloat m_Scale;
    GLfloat m_Squash;
    GLfloat m_Angle;
    GLfloat m_Pos[3];
    GLfloat m_RotationalIncrement;
}
-(bool) execute;
-(id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat)squash textureFile:(NSString *)textureFile;
-(GLKTextureInfo *) loadTexture:(NSString *) filename;
-(void) getPositionX:(GLfloat*)x Y:(GLfloat*)y Z:(GLfloat*)z;
-(void) setPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
-(GLfloat) getRotation;
-(void) setRotation:(GLfloat)angle;
-(GLfloat)getRotationalIncrement;
-(void) setRotationalIncrement:(GLfloat)inc;
-(void) incrementRotation;
-(void) swapTexture:(NSString*)textureFile;

@end