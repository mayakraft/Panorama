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
    [panoramaView addButton:button1 toPositionVector:GLKVector3Make(0, 0, 0.1)];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor redColor];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button2 toPositionVector:GLKVector3Make(-10, 0, 0.1)];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.backgroundColor = [UIColor greenColor];
    button3.tag = 3;
    [button3 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button3 toPositionVector:GLKVector3Make(10, 0, 0.1)];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.backgroundColor = [UIColor yellowColor];
    button4.tag = 4;
    [button4 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button4 toPositionVector:GLKVector3Make(0, 0, -0.1)];
    
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    button5.backgroundColor = [UIColor purpleColor];
    button5.tag = 5;
    [button5 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button5 toPositionVector:GLKVector3Make(0.04142, 0, 0.1)];
    
    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    button6.backgroundColor = [UIColor blackColor];
    button6.tag = 6;
    [button6 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button6 toPositionVector:GLKVector3Make(0.1, 0, 0.1)];
    
    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeCustom];
    button7.backgroundColor = [UIColor grayColor];
    button7.tag = 7;
    [button7 addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [panoramaView addButton:button7 toPositionVector:GLKVector3Make(0.24142, 0, 0.1)];
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
