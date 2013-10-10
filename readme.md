# Spherical Panorama
### 360°×180° virtual window for iOS
* equirectangular 2:1 image projection
* OpenGL
* accelerometer-oriented

example source data:
![like this](https://raw.github.com/robbykraft/SphericalPanorama/master/360%20Panorama/park_2048.png)

## setup:

declare your view controller a subclass of GLKViewController

initialize PanoramaView:

'''objective-c
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[panoramaView setTexture:@"park_2048.png"];
[panoramaView beginUpdates];
[self setView:panoramaView];
'''

glkView drawInRect:

'''objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}
'''