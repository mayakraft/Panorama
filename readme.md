# Spherical Panorama
### 360° virtual reality window for iOS
* reads an equirectangular projection
* accelerometer-oriented
* OpenGL acceleration

example source data:
![like this](https://raw.github.com/robbykraft/SphericalPanorama/master/360%20Panorama/park_2048.png)

## setup

initialize PanoramaView:

```objective-c
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[panoramaView setTexture:@"forest.png"];
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

* set UIDeviceOrientation to Portrait
* texture size must be 2:1 Width:Height, and each dimension must be 2^n × (2^n)/2
* texture size limited to 4096 × 2048 on newer hardware, older hardware (iPhone 4, 3G) is 2048 × 1024
* include frameworks: OpenGLES, GLKit, CoreMotion

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

this gets multiplied by the following matrix, which amounts to a 90° rotation around the X axis

```
1  0  0  0
0  0 -1  0
0  1  0  0
0  0  0  1
```

which is an identity matrix with the following formula on the Y and Z axis

![wikipedia](http://upload.wikimedia.org/math/d/f/a/dfa9eccf5f8f2de1ac8ee1134ba88a86.png)

now we have the attitude matrix. multiply it on the scene each time the scene is rendered

```c++
glMultMatrixf(_attitudeMatrix.m);
```