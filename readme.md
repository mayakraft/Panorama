# 360° virtual reality window
### for equirectangular projections
simple device-oriented panoramic image view for iOS devices

* equirectangular is the format most panorama stitch apps use
* calibrated for Apple devices’ orientation matrix (accelerometer + gyro)

example source data:

![like this](https://raw.github.com/robbykraft/Spherical/master/Spherical/park_small.jpg)

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
Equirectangular images mapped to the inside of a sphere come out looking like the original scene. Camera should be at the exact center

CMMotionManager provides a matrix of three 3D vectors which describes the device orientation.
* OpenGL = column major, vectors are stored vertically.

```objective-c
CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
GLKMatrix4Make(
a.m11, a.m21, a.m31, 0.0f,  // x x x 0
a.m12, a.m22, a.m32, 0.0f,  // y y y 0
a.m13, a.m23, a.m33, 0.0f,  // z z z 0
0.0f , 0.0f , 0.0f , 1.0f); // 0 0 0 1
```

for Apple devices, to get the Y up / X across / Z out, multiply by a 90° rotation around the X axis.

now we have the device's orientation, multiply this matrix onto the scene with:

```c++
glMultMatrixf(_attitudeMatrix.m);
```