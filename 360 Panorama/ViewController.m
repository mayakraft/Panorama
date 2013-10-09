//
//  ViewController.m
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ViewController.h"

#define FOV 90

@implementation ViewController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize texturePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [(GLKView*)self.view setContext:self.context];
    [(GLKView*)self.view setDrawableDepthFormat:GLKViewDrawableDepthFormat24];
    
    [EAGLContext setCurrentContext:self.context];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    glController = [[GLController alloc] initWithTexture:@"park_2048.png"];
    
    // init lighting
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    glEnable(GL_LIGHTING);
    
    ///////////////////////////////////////////////////////////////////////////////
    lastPinchScale = 1.0;
    
    glMatrixMode(GL_PROJECTION);    // the frustum affects the projection matrix
    glLoadIdentity();               // not the model matrix
    //[self.view setTransform:CGAffineTransformMakeRotation(M_PI*.5)];
    //    aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    aspectRatio = (float)[[UIScreen mainScreen] bounds].size.height / (float)[[UIScreen mainScreen] bounds].size.width;
    int fov = FOV;
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(fov) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // funny this stuff just doesn't work in viewDidLoad
    [(GLKView*)self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
    [(GLKView*)self.view setTransform:CGAffineTransformMakeRotation(M_PI*.5)];
    [(GLKView*)self.view setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width*.5, [[UIScreen mainScreen] bounds].size.height*.5)];
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [glController execute];
}

-(void) tapHandler:(UITapGestureRecognizer*)sender{
}

-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    if([sender state] == 2){
        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
        glLoadIdentity();
        GLfloat fov = FOV /( lastPinchScale * [sender scale]);
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
        if(lastPinchScale < .75) lastPinchScale = .75;
        if(lastPinchScale > 2.0) lastPinchScale = 2.0;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end