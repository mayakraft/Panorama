//
//  Sphere.h
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//
//  adapted from Pro OpenGL ES for iOS
//  by Mike Smithwick
//  ISBN: 9781430238409 Jan 2011
//  pg. 78
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <GLKit/GLKit.h>

@interface Sphere : NSObject {
    
@private
    GLKTextureInfo *m_TextureInfo;
    GLfloat *m_TexCoordsData;
    GLfloat *m_VertexData;
    GLfloat *m_NormalData;
    GLint m_Stacks, m_Slices;
    GLfloat m_Scale;
}
-(bool) execute;
-(id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius textureFile:(NSString *)textureFile;
-(GLKTextureInfo *) loadTextureFromBundle:(NSString *) filename;
-(GLKTextureInfo *) loadTextureFromPath:(NSString *) path;
-(void) swapTexture:(NSString*)textureFile;

@end