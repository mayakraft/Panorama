//
//  ViewController.h
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES1/gl.h>
#import <CoreMotion/CoreMotion.h>
#import "GLController.h"

@interface ViewController : GLKViewController{
    GLController *glController;
    CMMotionManager *motionManager;
    NSArray *textures;
    CADisplayLink *displayLink;
    NSInteger clock;
}
@property (strong,nonatomic) EAGLContext *context;
@property (strong,nonatomic) GLKBaseEffect *effect;

@end
