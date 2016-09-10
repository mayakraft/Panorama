# 360° panorama view
### equirectangular projections

OpenGL, device-oriented, touch-interactive

![example](https://68.media.tumblr.com/befc76dfe47c212d1af30e8bef87672a/tumblr_od5kdgZ0Iv1vfq168o1_500.gif)

acceptable image sizes: (4096×2048), 2048×1024, 1024×512, 512×256, 256×128 ...

* (4096 supported on iPhone 4s and iPad2 onward)

#methods

### image

```objective-c
-(void) setImage:(UIImage*)image;
-(void) setImageWithName:(NSString*)fileName;  // path or bundle. will check at both
```

### orientation

```objective-c
 // auto-update (usually only one of these at a time is recommended)
-(void) setOrientToDevice:(BOOL)   // activate motion sensors
-(void) setTouchToPan:(BOOL)       // activate UIPanGesture

 // aligns z-axis (into screen)
-(void) orientToVector:(GLKVector3)
-(void) orientToAzimuth:(float) Altitude:(float)
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

# usage

make your `ViewController` a subclass of `GLKViewController`

```objective-c
panoramaView = [[PanoramaView alloc] init];
 // load image and any other customization
[self setView:panoramaView];
```

also in your `GLKViewController`:

```objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView draw];
}
```

### make sure

* no device landscape/portrait auto-rotation

![device](https://raw.github.com/robbykraft/Panorama/master/readme/device_orient.png)

* works properly under any of the 4 device orientations

# swift

```swift
class MainView: GLKViewController {
    
    var panoramaView = PanoramaView()
    
    override func viewDidLoad() {
        panoramaView.setImageWithName("imagename.jpg")
        panoramaView.touchToPan = true          // Use touch input to pan
        panoramaView.orientToDevice = false     // Use motion sensors to pan
        panoramaView.pinchToZoom = true         // Use pinch gesture to zoom
        panoramaView.showTouches = true         // Show touches
        self.view = panoramaView
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        panoramaView.draw()
    }
}
```

# orientation

* __azimuth__ and __altitude__
* __look direction__, the Z vector pointing through the center of the screen

![coordinates](http://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Azimuth-Altitude_schematic.svg/500px-Azimuth-Altitude_schematic.svg.png)

The program begins by facing the center column of the image, or azimuth 0°

![wikipedia](https://raw.github.com/robbykraft/Panorama/master/readme/azimuth-altitude-pixels.png)

# about equirectangular

![sample](https://raw.github.com/robbykraft/Panorama/master/readme/park_small.jpg)

equirectangular images mapped to the inside of a celestial sphere come out looking like the original scene, and the math is relatively simple [http://en.wikipedia.org/wiki/Equirectangular_projection](http://en.wikipedia.org/wiki/Equirectangular_projection)

# license

MIT
