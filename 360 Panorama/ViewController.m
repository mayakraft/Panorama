//
//  ViewController.m
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ViewController.h"
#import "PanoramaView.h"

@interface ViewController (){
    PanoramaView *panoramaView;
    NSArray *images;
    NSInteger image;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    images = @[@"Tycho_4096_city_r.jpg", @"Tycho_4096_r.jpg", @"cave_4096.jpg",@"park_4096.jpg"];
    images = @[@"Tycho_2048_city_r.png",@"Planck_CMB_red_2048_r.png"];
    [panoramaView setPlanetaryTexture:@"outside_transparent_2048.png"];
    [panoramaView setCelestialTexture:images[0]];
    [panoramaView setOrientToDevice:YES];   // initialize device orientation sensors
    [panoramaView setPinchZoom:YES];   // activate touch gesture, alters field of view
    [self setView:panoramaView];
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}

@end