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
	[panoramaView setImageWithName:@"park_2048.jpg"];
	[panoramaView setOrientToDevice:YES];
	[panoramaView setTouchToPan:NO];
	[panoramaView setPinchToZoom:YES];
	[panoramaView setShowTouches:NO];
	[panoramaView setVRMode:NO];
	[self setView:panoramaView];
    [self setupButtons];
}


- (void)setupButtons {
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.backgroundColor = [UIColor blueColor];
    button1.tag = 1;
    [button1 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button1 toPositionVector:[PanoramaView vector3FromAngleDegree:0]];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor redColor];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button2 toPositionVector:[PanoramaView vector3FromAngleDegree:90]];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.backgroundColor = [UIColor greenColor];
    button3.tag = 3;
    [button3 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button3 toPositionVector:[PanoramaView vector3FromAngleDegree:-90]];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.backgroundColor = [UIColor yellowColor];
    button4.tag = 4;
    [button4 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button4 toPositionVector:[PanoramaView vector3FromAngleDegree:180]];
    
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    button5.backgroundColor = [UIColor grayColor];
    button5.tag = 5;
    [button5 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button5 toPositionVector:[PanoramaView vector3FromAngleDegree:45]];

    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    button6.backgroundColor = [UIColor grayColor];
    button6.tag = 6;
    [button6 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button6 toPositionVector:[PanoramaView vector3FromAngleDegree:-45]];

    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeCustom];
    button7.backgroundColor = [UIColor grayColor];
    button7.tag = 7;
    [button7 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button7 toPositionVector:[PanoramaView vector3FromAngleDegree:135]];
    
    UIButton *button8 = [UIButton buttonWithType:UIButtonTypeCustom];
    button8.backgroundColor = [UIColor grayColor];
    button8.tag = 8;
    [button8 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button8 toPositionVector:[PanoramaView vector3FromAngleDegree:-135]];
}


- (void)didPressButton:(UIButton *)button {
    NSLog(@"didPressButton withTag: %ld", (long)button.tag);
}


-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
	[panoramaView draw];
}


// uncomment everything below to make a VR-Mode switching button

//-(void) viewWillAppear:(BOOL)animated{
//	[super viewWillAppear:animated];
//	CGFloat PAD = 15.0;
//	UIButton *VRButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
//	[VRButton setTransform:CGAffineTransformMakeRotation(M_PI*0.5)];
//	[VRButton setCenter:CGPointMake(VRButton.frame.size.width*0.5 + PAD,
//									self.view.bounds.size.height - VRButton.frame.size.height*0.5 - PAD)];
//	[VRButton setImage:[UIImage imageNamed:@"button-screen-double"] forState:UIControlStateNormal];
//	[VRButton setAlpha:0.5];
//	[VRButton addTarget:self action:@selector(vrButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:VRButton];
//}
//-(void) vrButtonHandler:(UIButton*)sender{
//	[panoramaView setVRMode:!panoramaView.VRMode];
//	if(panoramaView.VRMode){
//		[sender setImage:[UIImage imageNamed:@"button-screen-single"] forState:UIControlStateNormal];
//	}else{
//		[sender setImage:[UIImage imageNamed:@"button-screen-double"] forState:UIControlStateNormal];
//	}
//}

@end
