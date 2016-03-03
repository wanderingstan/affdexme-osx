//
//  ViewController.h
//  faceDetection
//
//  Created by Affectiva on 2/22/13.
//  Copyright (c) 2013 Affectiva All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Affdex/Affdex.h>
#import <AVFoundation/AVFoundation.h>
#import "ExpressionViewController.h"

@interface ViewController : NSViewController <AVCaptureVideoDataOutputSampleBufferDelegate, AFDXDetectorDelegate>

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSImageView *processedImageView;
@property (strong) AVCaptureSession *session;
@property dispatch_queue_t process_queue;
@property (weak) IBOutlet NSTextField *fps;
@property (weak) IBOutlet NSTextField *fpsProcessed;
@property (weak) IBOutlet NSTextField *detectors;
@property (weak) IBOutlet NSTextField *appleDetectors;
@property (strong) AFDXDetector *detector;
@property (assign) BOOL drawFacePoints;
@property (assign) BOOL drawFaceBox;
@property (assign) CGFloat pointSize;
@property (strong) NSMutableDictionary *faceMeasurements;

@end
