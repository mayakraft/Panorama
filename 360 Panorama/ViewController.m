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
    images = @[@"Tycho_4096_city2_r.jpg", @"Tycho_4096_r.jpg", @"cave_4096.jpg",@"park_4096.jpg"];
//    images = @[@"Tycho_4096_r.png",@"park_2048.png",@"Planck_CMB_red_2048_r.png"];
    [panoramaView setTexture:images[0]];
    [panoramaView setOrientToDevice:YES];   // initialize device orientation sensors
    [panoramaView setPinchZoom:YES];   // activate touch gesture, alters field of view
    [self setView:panoramaView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [tapGesture setNumberOfTapsRequired:3];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}

-(void) tapHandler:(UITapGestureRecognizer*)sender{
    image++;
    if(image >= images.count)
        image = 0;
    [panoramaView setTexture:images[image]];
}

@end