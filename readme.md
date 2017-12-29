# 360° spherical panorama view

## Features

* OpenGL powered
* orientation sensors to look around
* touch interactive
  * pan to look around
  * pinch to zoom
* a split screen mode for VR headsets
* helper functions to orient direction of camera and touches

![example](https://68.media.tumblr.com/befc76dfe47c212d1af30e8bef87672a/tumblr_od5kdgZ0Iv1vfq168o1_500.gif)

## Equirectangular projections

*OpenGL has strict texture size requirements*

acceptable image sizes:

* 4096 × 2048
* 2048 × 1024
* 1024 × 512
* 512 × 256
* 256 × 128
* ... (any smaller power of 2)

*4096 supported on iPhone 4s / iPad2 and newer*

## Methods

### image

```objective-c
-(void) setImage:(UIImage*)image
-(void) setImageWithName:(NSString*)fileName  // path or bundle. will check at both
```

### orientation

```objective-c
 // auto-update (usually only one of these at a time is recommended)
-(void) setOrientToDevice:(BOOL)   // activate motion sensors
-(void) setTouchToPan:(BOOL)       // activate UIPanGesture

 // aligns z-axis (into screen)
-(void) orientToVector:(GLKVector3)
-(void) orientToAzimuth:(float) Altitude:(float)

// rotate cardinal north around the image horizon. in degrees
-(void) setCardinalOffset:(float)
```

### field of view

```objective-c
-(void) setFieldOfView:(float)     // in degrees
-(void) setPinchToZoom:(BOOL)      // activate UIPinchGesture
```

### touches

```objective-c
-(void) setShowTouches:(BOOL)      // overlay latitude longitude intersects
-(BOOL) touchInRect:(CGRect)       // hotspot detection in world coordinates
```

### 2D - 3D conversion

```objective-c
-(CGPoint) screenLocationFromVector:(GLKVector3) // 2D screen point from a 3D point
-(GLKVector3) vectorFromScreenLocation:(CGPoint) // 3D point from 2D screen point
-(CGPoint) imagePixelAtScreenLocation:(CGPoint)  // 3D point from 2D screen point
  // except this 3D point is expressed as 2D pixel unit in the panorama image
```

### VR Split screen

```objective-c
-(void) setVRMode:(BOOL)
```

This activates a split screen that works inside of VR headsets like Google Cardboard. TBD if more VR best practices are needed, such as a barrel shader.

* Illusion of varying depth is not available. The two screens are rendered using the same image with no difference between camera IPD.

## Installation

copy PanoramaView.h/.m into your project or use [CocoaPods](https://cocoapods.org/pods/PanoramaView)

1. use a `GLKViewController` instead of `UIViewController`
2. initialize your panoramaView and set it as `self.view`
3. implement glkView:drawInRect:

```objective-c
@interface ViewController (){
	PanoramaView *panoramaView;
}
@end

@implementation ViewController
- (void)viewDidLoad{
	[super viewDidLoad];
	panoramaView = [[PanoramaView alloc] init];
	[panoramaView setImageWithName:@"image.jpg"];
	[self setView:panoramaView];
}
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
	[panoramaView draw];
}
@end
```

## Swift

* installation is easiest with [CocoaPods](https://cocoapods.org/pods/PanoramaView). add `use_frameworks!` to your podfile
* or, create a bridging header, copy in PanoramaView.h/.m

```swift
import PanoramaView

class ViewController: GLKViewController {

	let panoramaView:PanoramaView

	required init?(coder aDecoder: NSCoder) {
		panoramaView = PanoramaView()
		super.init(coder: aDecoder)
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		panoramaView.setImageWithName("image.jpg")
		self.view = panoramaView
	}
	override func glkView(_ view: GLKView, drawIn rect: CGRect) {
		panoramaView.draw()
	}
}
```

### make sure

* no device landscape/portrait auto-rotation

![device](https://raw.github.com/robbykraft/Panorama/master/readme/device_orient.png)

* any of the 4 device orientations works, use only 1.

## Orientation

* __azimuth__ and __altitude__
* __look direction__, the Z vector pointing through the center of the screen

![coordinates](http://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Azimuth-Altitude_schematic.svg/500px-Azimuth-Altitude_schematic.svg.png)

The program begins by facing the center column of the image, or azimuth 0°

![wikipedia](https://raw.github.com/robbykraft/Panorama/master/readme/azimuth-altitude-pixels.png)

## About equirectangular

![sample](https://raw.github.com/robbykraft/Panorama/master/readme/park_small.jpg)

equirectangular images mapped to the inside of a celestial sphere come out looking like the original scene, and the math is relatively simple [http://en.wikipedia.org/wiki/Equirectangular_projection](http://en.wikipedia.org/wiki/Equirectangular_projection)

## License

MIT
