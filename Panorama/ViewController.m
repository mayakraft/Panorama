//
//  ViewController.m
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All Rights Reserved.
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
    panoramaView = [[PanoramaView alloc] init];
    [panoramaView setImage:@"park_2048.jpg"];
    [panoramaView setOrientToDevice:YES];
//    [panoramaView setTouchToPan:YES];
    [panoramaView setPinchToZoom:YES];
    [panoramaView setShowTouches:YES];
    [self setView:panoramaView];
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView draw];
}

@end