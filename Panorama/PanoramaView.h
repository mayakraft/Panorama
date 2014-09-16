#import <Foundation/Foundation.h>

/**
 * @class Panorama View
 * @author Robby Kraft
 * @date 8/24/13
 *
 * @availability iOS (5.0 and later)
 *
 * @discussion a dynamic GLKView with a touch and motion sensor interface to align and immerse the perspective inside an equirectangular panorama projection
 */
@interface PanoramaView : GLKView


-(id) init;  // recommended init method

-(void) draw;  // place in GLKViewController's glkView:drawInRect:

/// Set image by path or bundle - will check at both
-(void) setImage:(NSString*)fileName;


/* orientation */

/// forward vector axis (into the screen)
@property (nonatomic, readonly) GLKVector3 lookVector;

/// forward horizontal azimuth (-π to π)
@property (nonatomic, readonly) float lookAzimuth;

/// forward vertical altitude (-.5π to .5π)
@property (nonatomic, readonly) float lookAltitude;


// At this point, it's still recommended to activate either OrientToDevice or TouchToPan, not both
//   it's possible to have them simultaneously, but the effect is confusing and disorienting


/// Activates accelerometer + gyro orientation
@property (nonatomic) BOOL orientToDevice;

/// Enables UIPanGestureRecognizer to affect view orientation
@property (nonatomic) BOOL touchToPan;

/// Fixes up-vector during panning. (trade off: no panning past the poles)
//@property (nonatomic) BOOL preventHeadTilt;

/**
 * Align Z coordinate axis (into the screen) to a GLKVector.
 * (due to a fixed up-vector, flipping will occur at the poles)
 *
 * @param GLKVector3 can be non-normalized
 */
-(void) orientToVector:(GLKVector3)vector;

/**
 * Align Z coordinate axis (into the screen) to azimuth and altitude.
 * (due to a fixed up-vector, flipping will occur at the poles)
 *
 * @param Azimuth(-π to π) Altitude(-.5π to .5π)
 */
-(void) orientToAzimuth:(float) azimuth Altitude:(float)altitude;


/*  projection & touches  */


@property (nonatomic, readonly) NSSet *touches;

@property (nonatomic, readonly) NSInteger numberOfTouches;

/// Field of view in DEGREES
@property (nonatomic) float fieldOfView;

/// Enables UIPinchGestureRecognizer to affect FieldOfView
@property (nonatomic) BOOL pinchToZoom;

/// Dynamic overlay of latitude and longitude intersection lines for all touches
@property (nonatomic) BOOL showTouches;
/**
 * Converts screen coordinate to image pixel coordinate
 *
 * @param CGPoint device screen coordinate
 * @return CGPoint image coordinate in pixels, or betwee 0.0 and 1.0 if no image
 */
-(CGPoint) imagePixelAtScreenLocation:(CGPoint)point;
/**
 * Hit-detection for all active touches
 *
 * @param CGRect defined in image pixel coordinates
 * @return YES if touch is inside CGRect, NO otherwise
 */
-(BOOL) touchInRect:(CGRect)rect;


@end

