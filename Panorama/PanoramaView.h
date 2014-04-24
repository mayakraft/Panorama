//
//  PanoramaView.h
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//  MIT license
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface PanoramaView : GLKView

-(void) draw;
-(void) setTexture:(NSString*)fileName;
-(CGPoint) imagePixelFromScreenLocation:(CGPoint)point;  // Panorama pixel from screen point

@property (nonatomic) BOOL orientToDevice;  // activate motion sensors

@property (nonatomic) BOOL pinchZoom;
@property (nonatomic) float fieldOfView;

@property (nonatomic) NSSet *touches;
@property (nonatomic) NSInteger numberOfTouches;
@property (nonatomic) BOOL showTouches;  // Lat Long lines for touch -> 3D conversion

@property (nonatomic, readonly) GLKVector3 lookVector; // forward vector
@property (nonatomic, readonly) float lookAzimuth;    //  -π to π
@property (nonatomic, readonly) float lookAltitude;  // -.5π to .5π

@end
