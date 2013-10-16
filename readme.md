# Spherical Panorama
### 360° virtual reality window for iOS
* uses an equirectangular 2:1 image projection
* accelerometer-oriented
* OpenGL accelerated

example source data:
![like this](https://raw.github.com/robbykraft/SphericalPanorama/master/360%20Panorama/park_2048.png)

## setup

initialize PanoramaView:

```objective-c
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[panoramaView setTexture:@"park_2048.png"];
[panoramaView setHardwareOrientationActive:YES];   // initialize device orientation sensors
[self setView:panoramaView];
```

redraw screen:

```objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}
```

make sure to subclass:

```objective-c
@interface ViewController : GLKViewController
@end
```

* Portrait mode only right now
* OpenGL texture size 1:2, H:W, and pixels must be 2^n × (2^n)/2
* iOS hardware limited to 4096 × 2048, older hardware (iPhone 4, 3G) 2048 × 1024
* include frameworks: OpenGLES, GLKit, CoreMotion