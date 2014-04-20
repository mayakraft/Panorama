//
//  ViewController.m
//  Panorama
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
    [panoramaView setTexture:@"park_2048.jpg"];
    [panoramaView setOrientToDevice:YES];  // YES: use accel/gyro. NO: use touch pan gesture
    [panoramaView setPinchZoom:YES];  // pinch to change field of view
    [self setView:panoramaView];
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView draw];
}

@end