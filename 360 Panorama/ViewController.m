//
//  ViewController.m
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        textures = [NSArray arrayWithObjects:@"park.jpg", @"marsh.jpg", @"narthex.png", @"cave.jpg", @"station.jpg", @"snow_small.jpg", @"office.jpg", nil];
    else
        textures = [NSArray arrayWithObjects:@"narthex.png",nil];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    GLKView *view = (GLKView*)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [self.view addGestureRecognizer:swipeGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    glController = [[GLController alloc] initWithTexture:[textures objectAtIndex:arc4random()%[textures count]]];
    
    // init lighting
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    glEnable(GL_LIGHTING);
    
    ///////////////////////////////////////////////////////////////////////////////
    lastPinchScale = 1.0;
    
    glMatrixMode(GL_PROJECTION);    // the frustum affects the projection matrix
    glLoadIdentity();               // not the model matrix
    if(self.interfaceOrientation == 3 || self.interfaceOrientation == 4)
        aspectRatio = (float)[[UIScreen mainScreen] bounds].size.height / (float)[[UIScreen mainScreen] bounds].size.width;
    else
        aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    int fov = 60;
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(fov) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    ///////////////////////////////////////////////////////////////////////////////
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.0/15.0;
    if(motionManager.isDeviceMotionAvailable){
        [motionManager startDeviceMotionUpdates];
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *deviceMotion, NSError *error){
            CMAttitude *attitude = deviceMotion.attitude;
            [glController setEyeRotationX:(attitude.roll+M_PI/2.0)*180/M_PI Y:(-attitude.yaw)*180/M_PI Z:attitude.pitch*180/M_PI];
            clock++;
            if(clock >= 15){
                clock = 0;
                NSLog(@"++++++++++++++++++++++++++++++++++++++++++++");
                NSLog(@"(P:%.2f, R:%.2f, Y:%.2f)",(attitude.roll+M_PI/2.0)*180/M_PI, attitude.pitch*180/M_PI, (-attitude.yaw)*180/M_PI);
                NSLog(@"--------------------------------------------");
            }
        }];
    }
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [glController execute];
}

-(void)swipeHandler:(UISwipeGestureRecognizer*)sender{
    [glController swapTexture:[textures objectAtIndex:arc4random()%[textures count]]];
}

-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    if([sender state] == 2){
        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
        glLoadIdentity();
        GLfloat fov = 60 /( lastPinchScale * [sender scale]);
        if(fov < 45) fov = 45;
        if(fov > 120) fov = 120;
        float zNear = 0.1;
        float zFar = 1000;
        GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(fov) / 2.0);
        glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
        glMatrixMode(GL_MODELVIEW);
        glPopMatrix();
    }
    else if([sender state] == 3){
        lastPinchScale *= [sender scale];
        if(lastPinchScale < .5) lastPinchScale = .5;
        if(lastPinchScale > 1.333333) lastPinchScale = 1.333333;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end