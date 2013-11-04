# Spherical Panorama
### 360° virtual reality window for iOS
* reads an equirectangular projection - the same format that panorama-stitch apps use
* accelerometer-oriented
* OpenGL acceleration

example source data:
![like this](https://raw.github.com/robbykraft/SphericalPanorama/master/360%20Panorama/park_2048.png)
acceptable sizes: (4096×2048), 2048×1024, 1024×512, 512×256, 256×128 ...

* (devices after 2012)

## setup

```objective-c
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[panoramaView setTexture:@"panorama.png"];
[panoramaView setOrientToDevice:YES];   // initialize device orientation sensors
[panoramaView setPinchZoom:YES];   // activate touch gesture, alters field of view
[self setView:panoramaView];
```

redraw screen:

```objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}
```

### make sure
* to subclass:

```objective-c
@interface ViewController : GLKViewController
```

* set UIDeviceOrientation to only-Portrait

## what's going on?

CMMotionManager provides a matrix of three 3D vectors to describe the device orientation.
* GL matrices uses column major, so vectors are stored vertically.

```objective-c
CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
GLKMatrix4Make(
a.m11, a.m21, a.m31, 0.0f,  // x x x 0
a.m12, a.m22, a.m32, 0.0f,  // y y y 0
a.m13, a.m23, a.m33, 0.0f,  // z z z 0
0.0f , 0.0f , 0.0f , 1.0f); // 0 0 0 1
```

for apple devices, to get the Y up, X across, and Z out, multiply the attitude matrix by the following matrix, a 90° rotation around the X axis

```
1  0  0  0
0  0 -1  0
0  1  0  0
0  0  0  1
```

it's pretty easy to recognize the formula for 2D rotation inside the 3D rotation

![wikipedia](http://upload.wikimedia.org/math/d/f/a/dfa9eccf5f8f2de1ac8ee1134ba88a86.png)

* cos(90°) = 0
* sin(90°) = 1

now we have the device's orientation, multiply each time the scene is rendered

```c++
glMultMatrixf(_attitudeMatrix.m);
```