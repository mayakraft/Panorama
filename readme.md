# 360° virtual reality window
### for equirectangular projections
simple device-oriented panoramic image view for iOS devices

* equirectangular is the format most panorama stitch apps use
* calibrated for Apple devices’ orientation matrix (accelerometer + gyro)

example source data:

![sample](https://raw.github.com/robbykraft/Panorama/master/Panorama/park_small.jpg)

acceptable image sizes: (4096×2048), 2048×1024, 1024×512, 512×256, 256×128 ...

* (devices after 2012)

## setup

from an empty project include `PanoramaView.h & .m` and `Sphere.h & .m` and an image file (image is mirrored, flip image horizontally)

in your `ViewController.m`, typically in `viewDidLoad`:

```objective-c
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[panoramaView setTexture:@"panorama.png"];
[panoramaView setOrientToDevice:YES];   // initialize device orientation sensors
[panoramaView setPinchZoom:YES];   // activate touch gesture, alters field of view
[self setView:panoramaView];
```

also add this to `ViewController.m`:

```objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}
```

### make sure
* to subclass ViewController:

```objective-c
@interface ViewController : GLKViewController
```

* force device orientation to only-Portrait
* image is sized properly (read above)

## what's going on?
Equirectangular images mapped to the inside of a sphere come out looking like the original scene. Camera should be at the exact center.

Orientation is set by setting the device orientation matrix. It can be set:

* automatically from the device orientation (CMMotionManager)
* manually as such:

```objective-c
GLKMatrix4Make(
a.m11, a.m21, a.m31, 0.0f,  // x1 x2 x3 0
a.m12, a.m22, a.m32, 0.0f,  // y1 y2 y3 0
a.m13, a.m23, a.m33, 0.0f,  // z1 z2 z3 0
0.0f , 0.0f , 0.0f , 1.0f); // 0  0  0  1
```
* in OpenGL, matrices are column major, vectors are stored vertically.

## Orientation

Class also provides read only __Azimuth__ and __Altitude__

![coordinates](http://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Azimuth-Altitude_schematic.svg/500px-Azimuth-Altitude_schematic.svg.png)

Azimuth 0° is based on the beginning orientation of the phone at the time of program start. It’s possible for CMMotionManager to activate the magnometer and align north to Earth’s magnetic north pole.