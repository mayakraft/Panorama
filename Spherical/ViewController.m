//
//  ViewController.m
//  Spherical
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ViewController.h"
#import "PanoramaView.h"

@interface ViewController (){
    PanoramaView *panoramaView;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [panoramaView setTexture:@"equirectangular-projection-lines.png"];
//    [panoramaView setTexture:@"park_2048.png"];
    [panoramaView setCelestialSphere:YES];  // spinning stars background
    [panoramaView setOrientToDevice:YES];  // initialize device orientation sensors
    [panoramaView setPinchZoom:YES];  // activate touch gesture, alters field of view
    [self setView:panoramaView];
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}

@end