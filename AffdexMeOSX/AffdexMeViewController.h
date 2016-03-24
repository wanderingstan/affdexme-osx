//
//  AffdexDemoViewController.h
//  faceDetection
//
//  Created by Affectiva on 2/22/13.
//  Copyright (c) 2016 Affectiva Inc.
//
//  See the file license.txt for copying permission.

#import <AVFoundation/AVFoundation.h>
#import "PreferencesWindowController.h"
#import "ExpressionViewController.h"
#import <Affdex/Affdex.h>

static NSString *FacePointsKey = @"drawFacePoints";
static NSString *FaceBoxKey = @"drawFaceBox";
static NSString *DrawDominantEmojiKey = @"drawDominantEmoji";
static NSString *DrawAppearanceIconsKey = @"drawAppearanceIcons";
static NSString *PointSizeKey = @"pointSize";
static NSString *ProcessRateKey = @"maxProcessRate";

@interface AffdexMeViewController : NSViewController <AFDXDetectorDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, NSSharingServicePickerDelegate>

@property (strong) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSImageView *processedImageView;
@property (strong) AVCaptureSession *session;
@property dispatch_queue_t process_queue;
@property (weak) IBOutlet NSTextField *fps;
@property (weak) IBOutlet NSTextField *fpsProcessed;
@property (weak) IBOutlet NSTextField *detectors;
@property (strong) AFDXDetector *detector;
@property (assign) BOOL drawFacePoints;
@property (assign) BOOL drawAppearanceIcons;
@property (assign) BOOL drawDominantEmoji;
@property (assign) BOOL drawFaceBox;
@property (assign) CGFloat pointSize;
@property (strong) NSMutableDictionary *faceMeasurements;
@property (weak) IBOutlet NSView *classifiersView;

@property (assign) BOOL selectedClassifiersDirty;
@property (assign) IBOutlet NSButton *shareButton;

@property (strong) PreferencesWindowController *preferencesWindowController;

- (NSError *)startDetector;
- (NSError *)stopDetector;

@end
