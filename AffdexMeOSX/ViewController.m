//
//  ViewController.m
//
//  Created by Affectiva on 2/22/13.
//  Copyright (c) 2013 Affectiva All rights reserved.
//

#import "ViewController.h"

#ifndef YOUR_AFFDEX_LICENSE_STRING_GOES_HERE
#error Please set the macro YOUR_AFFDEX_LICENSE_STRING_GOES_HERE to the contents of your Affectiva SDK license file.
#endif

@interface ViewController ()

@property float stretchFactorX;
@property float stretchFactorY;

@property (strong) NSDate *dateOfLastFrame;
@property (strong) NSDate *dateOfLastProcessedFrame;
@property (strong) NSDictionary *entries;
@property (strong) NSEnumerator *entryEnumerator;
@property (strong) NSDictionary *jsonEntry;
@property (strong) NSDictionary *videoEntry;
@property (strong) NSString *jsonFilename;
@property (strong) NSString *mediaFilename;

@property (strong) NSMutableArray *facePointsToDraw;
@property (strong) NSMutableArray *faceRectsToDraw;

@end

@implementation ViewController

#pragma mark
#pragma mark ViewController Delegate Methods

-(BOOL)canBecomeFirstResponder;
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pointSize = 3.0;
    [self prepDetectorWithFile:nil];
}

- (void)prepDetectorWithFile:(NSString *)file;
{
    [self.detector stop];
    
    // create our detector with our desired facial expresions, using the front facing camera
    self.detector = [[AFDXDetector alloc] initWithDelegate:self
                                               usingCamera:AFDX_CAMERA_FRONT maximumFaces:1];
    // tell the detector which facial expressions we want to measure
    self.detector.smile = TRUE;
    self.detector.browRaise = TRUE;
    self.detector.browFurrow = TRUE;
    self.detector.lipCornerDepressor = TRUE;
    self.detector.valence = TRUE;
    self.detector.engagement = TRUE;
    self.drawFacePoints = FALSE;
    self.drawFaceBox = FALSE;
    
    self.detector.maxProcessRate = 5.f;
    
    self.dateOfLastFrame = nil;
    self.dateOfLastProcessedFrame = nil;
    self.detector.licenseString = YOUR_AFFDEX_LICENSE_STRING_GOES_HERE;
    
    // let's start it up!
    NSError *error = [self.detector start];
    
    if (nil != error)
    {
        NSAlert *alert = [NSAlert new];
        alert.messageText = [error localizedDescription];
        [alert runModal];
    }
}


- (void)dealloc;
{
    self.detector = nil;
}

-(void)addSubView:(NSView *)highlightView withFrame:(CGRect)frame
{
    highlightView.frame = frame;
    highlightView.layer.borderWidth = 1;
    highlightView.layer.borderColor = [[NSColor whiteColor] CGColor];
    [self.imageView addSubview:highlightView];
}


#pragma mark -
#pragma mark AFDXDetectorDelegate Methods

- (void)detector:(AFDXDetector *)detector didStartDetectingFace:(AFDXFace *)face;
{
    // create the expression view controllers to hold the expressions for this face
    NSMutableArray *viewControllers = [NSMutableArray new];
    ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:@"SMILE"];
    [viewControllers addObject:vc];
    vc = [[ExpressionViewController alloc] initWithName:@"BROW RAISE"];
    [viewControllers addObject:vc];
    vc = [[ExpressionViewController alloc] initWithName:@"BROW FURROW"];
    [viewControllers addObject:vc];
    vc = [[ExpressionViewController alloc] initWithName:@"LIP DEPRESSOR"];
    [viewControllers addObject:vc];
    vc = [[ExpressionViewController alloc] initWithName:@"VALENCE"];
    [viewControllers addObject:vc];
    vc = [[ExpressionViewController alloc] initWithName:@"ENGAGEMENT"];
    [viewControllers addObject:vc];
    
    NSView *mainView = [[NSView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 0.0f, 0.0f)];
    [mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGFloat height = 0.0;
    CGFloat width = 0.0;
    
    for (ExpressionViewController *vc in viewControllers)
    {
        width = vc.view.frame.size.width;
        CGRect frame = vc.view.frame;
        frame.origin.y = height;
        vc.view.frame = frame;
        [mainView addSubview:vc.view];
        height += frame.size.height;
    }
    
    mainView.frame = CGRectMake(0.0, 0.0, width, height);
    [self.imageView addSubview:mainView];
    
    face.userInfo = @{@"view": mainView, @"viewControllers" : viewControllers};
}

- (void)detector:(AFDXDetector *)detector didStopDetectingFace:(AFDXFace *)face;
{
    NSDictionary *faceData = face.userInfo;
    NSView *view = [faceData objectForKey:@"view"];
    [view removeFromSuperview];
    
    face.userInfo = nil;
}

- (void)detector:(AFDXDetector *)detector hasImage:(NSImage *)image atTime:(NSTimeInterval)time;
{
    if (TRUE == self.drawFacePoints && TRUE == self.drawFaceBox)
    {
        [self.imageView setImage:[AFDXDetector imageByDrawingPoints:self.facePointsToDraw
                                                  andRectangles:self.faceRectsToDraw
                                                      andImages:nil
                                                     withRadius:self.pointSize
                                                usingPointColor:[NSColor greenColor]
                                            usingRectangleColor:[NSColor greenColor]
                                                usingImageRects:nil
                                                        onImage:image]];
    }
    else if (TRUE == self.drawFacePoints)
    {
        [self.imageView setImage:[AFDXDetector imageByDrawingPoints:self.facePointsToDraw
                                                  andRectangles:nil
                                                      andImages:nil
                                                     withRadius:self.pointSize
                                                usingPointColor:[NSColor greenColor]
                                            usingRectangleColor:[NSColor greenColor]
                                                usingImageRects:nil
                                                        onImage:image]];
    }
    else if (TRUE == self.drawFaceBox)
    {
        [self.imageView setImage:[AFDXDetector imageByDrawingPoints:nil
                                                  andRectangles:self.faceRectsToDraw
                                                      andImages:nil
                                                     withRadius:self.pointSize
                                                usingPointColor:[NSColor greenColor]
                                            usingRectangleColor:[NSColor greenColor]
                                                usingImageRects:nil
                                                        onImage:image]];
    }
    else
    {
        [self.imageView setImage:image];
    }
    
    // compute frames per second and show
    NSDate *now = [NSDate date];
    
    if (nil != self.dateOfLastFrame)
    {
        NSTimeInterval interval = [now timeIntervalSinceDate:self.dateOfLastFrame];
        
        if (interval > 0)
        {
            float fps = 1.0 / interval;
            self.fps.stringValue = [NSString stringWithFormat:@"FPS(C): %.1f", fps];
        }
    }
    
    self.dateOfLastFrame = now;
}

- (void)detector:(AFDXDetector *)detector hasImage:(NSImage *)image withResults:(NSMutableDictionary *)faces atTime:(NSTimeInterval)time;
{
    NSDate *now = [NSDate date];
    
    if (nil != self.dateOfLastProcessedFrame)
    {
        NSTimeInterval interval = [now timeIntervalSinceDate:self.dateOfLastProcessedFrame];
        
        if (interval > 0)
        {
            float fps = 1.0 / interval;
            self.fpsProcessed.stringValue = [NSString stringWithFormat:@"FPS(P): %.1f", fps];
        }
    }
    
    self.dateOfLastProcessedFrame = now;
    
    // setup arrays of points and rects
    self.facePointsToDraw = [NSMutableArray new];
    self.faceRectsToDraw = [NSMutableArray new];
    
    // Handle each metric in the array
    for (NSNumber *key in [faces allKeys])
    {
        AFDXFace *face = [faces objectForKey:key];
        NSDictionary *faceData = face.userInfo;
        NSView *expressionsView = [faceData objectForKey:@"view"];
        NSArray *viewControllers = [faceData objectForKey:@"viewControllers"];
        
        [self.facePointsToDraw addObjectsFromArray:face.facePoints];
        [self.faceRectsToDraw addObject:[NSValue valueWithRect:face.faceBounds]];
        
        CGRect frame = expressionsView.frame;
        frame.origin.x = face.faceBounds.origin.x + face.faceBounds.size.width;
        frame.origin.y = face.faceBounds.origin.y;
        expressionsView.frame = frame;
        for (ExpressionViewController *v in viewControllers)
        {
            if (NAN != face.expressions.smile && [v.name isEqualToString:@"SMILE"])
            {
                v.metric = face.expressions.smile;
            }
            else
                if (NAN != face.expressions.browRaise && [v.name isEqualToString:@"BROW RAISE"])
                {
                    v.metric = face.expressions.browRaise;
                }
                else
                    if (NAN != face.expressions.browFurrow && [v.name isEqualToString:@"BROW FURROW"])
                    {
                        v.metric = face.expressions.browFurrow;
                    }
                    else
                        if (NAN != face.expressions.lipCornerDepressor && [v.name isEqualToString:@"LIP DEPRESSOR"])
                        {
                            v.metric = face.expressions.lipCornerDepressor;
                        }
                        else
                            if (NAN != face.emotions.valence && [v.name isEqualToString:@"VALENCE"])
                            {
                                v.metric = face.emotions.valence;
                            }
                            else
                                if (NAN != face.emotions.engagement && [v.name isEqualToString:@"ENGAGEMENT"])
                                {
                                    v.metric = face.emotions.engagement;
                                }
        }
    }
}

- (void)detector:(AFDXDetector *)detector hasResults:(NSMutableDictionary *)faces forImage:(NSImage *)image atTime:(NSTimeInterval)time
{
    if (faces == nil)
    {
        [self detector:detector hasImage:image atTime:time];
    }
    else
    {
        [self detector:detector hasImage:image withResults:faces atTime:time];
    }
}

@end
