# 360° panorama view
### equirectangular projections

OpenGL, device-oriented, touch-interactive

![sample](https://raw.github.com/robbykraft/Panorama/master/readme/park_small.jpg)

acceptable image sizes: (4096×2048), 2048×1024, 1024×512, 512×256, 256×128 ...

* (4096 supported on iPhone 4s and iPad2 onward)

#methods

### image

```objective-c
-(void) setImage:(NSString*)fileName;  // path or bundle. will check at both
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

# orientation

* __azimuth__ and __altitude__
* __look direction__, the Z vector pointing through the center of the screen

![coordinates](http://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Azimuth-Altitude_schematic.svg/500px-Azimuth-Altitude_schematic.svg.png)

The program begins by facing the center column of the image, or azimuth 0°

![wikipedia](https://raw.github.com/robbykraft/Panorama/master/readme/azimuth-altitude-pixels.png)

# about equirectangular

equirectangular images mapped to the inside of a celestial sphere come out looking like the original scene, and the math is relatively simple [http://en.wikipedia.org/wiki/Equirectangular_projection](http://en.wikipedia.org/wiki/Equirectangular_projection)

# license

MIT