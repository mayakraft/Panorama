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
    [panoramaView setImage:[UIImage imageNamed:@"scene.jpg"]];
//	[panoramaView setImageWithName:@"cd-vr-3.jpg"];
	[panoramaView setOrientToDevice:YES];
	[panoramaView setTouchToPan:NO];
	[panoramaView setPinchToZoom:YES];
	[panoramaView setShowTouches:YES];
	[panoramaView setVRMode:YES];
	[self setView:panoramaView];
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
	[panoramaView draw];
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	CGFloat PAD = 15.0;
	UIButton *VRButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
	[VRButton setTransform:CGAffineTransformMakeRotation(M_PI*0.5)];
	[VRButton setCenter:CGPointMake(VRButton.frame.size.width*0.5 + PAD,
									self.view.bounds.size.height - VRButton.frame.size.height*0.5 - PAD)];
	[VRButton setImage:[UIImage imageNamed:@"button-screen-single"] forState:UIControlStateNormal];
	[VRButton setAlpha:0.5];
	[VRButton addTarget:self action:@selector(vrButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:VRButton];
}

-(void) vrButtonHandler:(UIButton*)sender{
	[panoramaView setVRMode:!panoramaView.VRMode];
	if(panoramaView.VRMode){
		[sender setImage:[UIImage imageNamed:@"button-screen-single"] forState:UIControlStateNormal];
	}else{
		[sender setImage:[UIImage imageNamed:@"button-screen-double"] forState:UIControlStateNormal];
	}
}

@end
