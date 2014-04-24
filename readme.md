# 360° panorama view
### equirectangular projections

OpenGL, device-oriented, with hotspot detection

![sample](https://raw.github.com/robbykraft/Panorama/master/readme/park_small.jpg)

acceptable image sizes (OpenGL): (4096×2048), 2048×1024, 1024×512, 512×256, 256×128 ...

* (4096 supported on iPhone 4s and iPad2 onward)

# methods

```objective-c
-(void) setTexture:(NSString*)fileName;

@property (nonatomic) BOOL orientToDevice; // activate/deactivate motion sensors

@property (nonatomic) BOOL pinchZoom;

@property (nonatomic) float fieldOfView;

@property (nonatomic) BOOL showTouches; // overlay Lat Long lines

-(CGPoint) imagePixelFromScreenLocation:(CGPoint)point;

```

# usage

make `ViewController` a subclass of `GLKViewController`

```objective-c
// init and add to screen
panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[self setView:panoramaView];
```

include this in `ViewController.m`:

```objective-c
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}
```

### make sure

* no device landscape/portrait auto-rotation

# orientation

* __azimuth__ and __altitude__
* __look direction__, the Z vector pointing through the center of the screen

![coordinates](http://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Azimuth-Altitude_schematic.svg/500px-Azimuth-Altitude_schematic.svg.png)

The program begins by facing the center column of the image, or azimuth 0°

![sample](https://raw.github.com/robbykraft/Panorama/master/readme/azimuth-altitude-pixels.png)

# about equirectangular

Equirectangular images mapped to the inside of a celestial sphere come out looking like the original scene, and the math relatively simple [http://en.wikipedia.org/wiki/Equirectangular_projection](http://en.wikipedia.org/wiki/Equirectangular_projection)

# license

MIT