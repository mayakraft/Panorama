//
//  PanoramaView.h
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All Rights Reserved.
//

#import <Foundation/Foundation.h>

@interface PanoramaView : GLKView

-(id) init;  // recommended init method. if landscape, corrects aspect-ratio. auto full-screen.
-(void) draw;
-(void) setImage:(NSString*)fileName;  // path or bundle. will check at both

/* all operatons are in RADIANS */

/* projection */
@property (nonatomic) float fieldOfView;
@property (nonatomic) BOOL pinchToZoom;  // pinch to change field of view
-(CGPoint) imagePixelAtScreenLocation:(CGPoint)point;  // which pixel did you touch?

/* orientation */
@property (nonatomic) BOOL orientToDevice;  // YES: activate accel/gyro. NO: use touch pan gesture
@property (nonatomic) BOOL touchToPan; // default: YES
// below uses gl look at, with a fixed up-vector, so flipping will occur at the poles
-(void) orientToVector:(GLKVector3)vector;
-(void) orientToAzimuth:(float) azimuth Altitude:(float)altitude;

@property (nonatomic, readonly) GLKVector3 lookVector; // forward vector
@property (nonatomic, readonly) float lookAzimuth;    //  -π to π
@property (nonatomic, readonly) float lookAltitude;  // -.5π to .5π

/* touches */
@property (nonatomic) BOOL showTouches;  // overlay latitude longitude lines
@property (nonatomic, readonly) NSSet *touches;
@property (nonatomic, readonly) NSInteger numberOfTouches;
-(bool) touchInRect:(CGRect)rect;  // hotspot touchInRect validation. rect defined by image pixel coordinates

@end
