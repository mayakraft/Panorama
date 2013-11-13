# 360° virtual reality window
### for equirectangular projections
* the same format most panorama stitch apps use
* accelerometer-oriented look around

example source data:

![like this](https://raw.github.com/robbykraft/Spherical/master/Spherical/park_small.png)

acceptable image sizes: (4096×2048), 2048×1024, 1024×512, 512×256, 256×128 ...

* (devices after 2012)

## setup

from an empty project include `PanoramaView.h & .m` and `Sphere.h & .m` and an image file

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
It’s quite simple- equirectangular images mapped to the inside of a sphere come out looking like the original scene. Place the camera at the center.

To map the orientation of the device to the orientation of the camera, CMMotionManager provides a matrix (of three 3D vectors) describing the device orientation.
* OpenGL uses column major, so vectors are stored vertically.

```objective-c
CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
GLKMatrix4Make(
a.m11, a.m21, a.m31, 0.0f,  // x x x 0
a.m12, a.m22, a.m32, 0.0f,  // y y y 0
a.m13, a.m23, a.m33, 0.0f,  // z z z 0
0.0f , 0.0f , 0.0f , 1.0f); // 0 0 0 1
```

for Apple devices, to get the Y up / X across / Z out, multiply the attitude matrix by a 90° rotation around the X axis

```
1  0  0  0
0  0 -1  0
0  1  0  0
0  0  0  1
```

it's pretty easy to recognize the formula for 2D rotation inside the 3D rotation

![wikipedia](http://upload.wikimedia.org/math/d/f/a/dfa9eccf5f8f2de1ac8ee1134ba88a86.png)

```
0 -1
1  0
```

now we have the device's orientation, multiply each time the scene is rendered

```c++
glMultMatrixf(_attitudeMatrix.m);
```