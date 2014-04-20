# 360° panorama view
## equirectangular projections

OpenGL, device-oriented, with hotspot detection

equirectangular image sample:

![sample](https://raw.github.com/robbykraft/Panorama/master/readme/park_small.jpg)

acceptable image sizes (OpenGL): (4096×2048), 2048×1024, 1024×512, 512×256, 256×128 ...

* (4096 supported on iPhone 4s and iPad2 onward)

## methods

make  `ViewController` a subclass of `GLKViewController`

```objective-c
// init, set texture, add to screen
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[panoramaView setTexture:@"panorama.png"];
[self setView:panoramaView];
```

```objective-c
// initialize device orientation
[panoramaView setOrientToDevice:YES];

// pinch to change field of view
[panoramaView setPinchZoom:YES];
```

include this in `ViewController.m`:

```objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}
```

```objective-c
// get (image) point from touch
-(GLKVector3) screenToVector:(CGPoint)screenTouch;
-(CGPoint) getPixel:(GLKVector3)vector;
```

### make sure
* prevent landscape/portrait auto-rotation, constrain the device orientation to only one

## orientation

* __rotation matrix__
* __look direction__, the Z vector pointing through the center of the screen
* __azimuth__ and __altitude__
* which __pixel (X,Y)__ is directly ahead

![coordinates](http://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Azimuth-Altitude_schematic.svg/500px-Azimuth-Altitude_schematic.svg.png)

The program begins by facing the center column of the image, or azimuth 0°.

![sample](https://raw.github.com/robbykraft/Panorama/master/readme/azimuth-altitude-pixels.png)

## what's going on?
Equirectangular images mapped to the inside of a sphere come out looking like the original scene. Camera should be at the exact center.

Orientation is set by setting the device orientation matrix. It can be set:

* automatically from the device orientation (CMMotionManager)
* manually:

```objective-c
GLKMatrix4Make(
a.m11, a.m21, a.m31, 0.0f,  // x1 x2 x3 0
a.m12, a.m22, a.m32, 0.0f,  // y1 y2 y3 0
a.m13, a.m23, a.m33, 0.0f,  // z1 z2 z3 0
0.0f , 0.0f , 0.0f , 1.0f); // 0  0  0  1
```
* in OpenGL, matrices are column major, vectors are stored vertically.