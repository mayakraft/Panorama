//
//  PanoramaView.h
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface PanoramaView : GLKView

@property (nonatomic) float fieldOfView;  // 60-90 is a decent start
@property (nonatomic) BOOL pinchZoom;
@property (nonatomic) BOOL orientToDevice;

@property (nonatomic) GLKMatrix4 attitudeMatrix;
@property (nonatomic, readonly) GLKVector3 lookVector;  // forward vector
@property (nonatomic, readonly) float lookAzimuth;  // -π to π
@property (nonatomic, readonly) float lookAltitude;  // -.5π to .5π

-(void) execute;  // draw screen
-(void) setTexture:(NSString*)fileName;
-(CGPoint) getLookPixel;

@end
