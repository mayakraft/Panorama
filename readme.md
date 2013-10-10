# Spherical Panorama
### 360° virtual reality window for iOS
* uses an equirectangular 2:1 image projection
* accelerometer-oriented
* OpenGL accelerated

example source data:
![like this](https://raw.github.com/robbykraft/SphericalPanorama/master/360%20Panorama/park_2048.png)

## setup:

* complete implementation included in ViewController.h & .m
* view controller is a subclass of GLKViewController

initialize PanoramaView:

```objective-c
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[panoramaView setTexture:@"park_2048.png"];
[panoramaView beginUpdates];  // initialize device orientation sensors
[self setView:panoramaView];
```

screen refresh:

```objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}
```

* OpenGL texture limitations 2^n × (2^n)/2
* iOS hardware limited to 4096 × 2048, older hardware (iPhone 4) 2048 × 1024