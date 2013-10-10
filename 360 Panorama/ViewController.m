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
    CGFloat zoom;
}
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [panoramaView setTexture:@"park_2048.png"];
    [panoramaView beginUpdates];  // initialize device orientation sensors
    [self setView:panoramaView];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [self.view addGestureRecognizer:pinchGesture];
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}

// simple pinch to zoom
-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    if([sender state] == 1)
        zoom = [panoramaView FOV];
    if([sender state] == 2){
        CGFloat newFOV = zoom / [sender scale];
        if(newFOV < 30) newFOV = 30;
        if(newFOV > 160) newFOV = 160;
        [panoramaView setFOV:newFOV];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end