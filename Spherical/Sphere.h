//
//  Sphere.h
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
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
-(GLKTextureInfo *) loadTexture:(NSString *) filename;
-(void) swapTexture:(NSString*)textureFile;

@end