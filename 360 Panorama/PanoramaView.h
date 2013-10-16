//
//  PanoramaView.h
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface PanoramaView : GLKView

@property (nonatomic) float FOV;
@property (nonatomic) BOOL hardwareOrientationActive;
@property (nonatomic) GLKMatrix4 deviceMotionAttitudeMatrix;

-(void) execute;  // draw screen
-(void) setTexture:(NSString*)fileName;
-(void) swapTexture:(NSString*)fileName;

@end
