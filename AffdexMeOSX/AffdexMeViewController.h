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

static NSString *kSelectedCameraKey = @"selectedCamera";
static NSString *kFacePointsKey = @"drawFacePoints";
static NSString *kFaceBoxKey = @"drawFaceBox";
static NSString *kDrawDominantEmojiKey = @"drawDominantEmoji";
static NSString *kDrawAppearanceIconsKey = @"drawAppearanceIcons";
static NSString *kDrawFrameRateKey = @"drawFrameRate";
static NSString *kDrawFramesToScreenKey = @"drawFramesToScreen";
static NSString *kPointSizeKey = @"pointSize";
static NSString *kProcessRateKey = @"maxProcessRate";
static NSString *kLogoSizeKey = @"logoSize";
static NSString *kLogoOpacityKey = @"logoOpacity";

@interface AffdexMeViewController : NSViewController <AFDXDetectorDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, NSSharingServicePickerDelegate, NSWindowDelegate>

@property (weak) IBOutlet NSView *mainView;
@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSView *logoView;
@property (weak) IBOutlet NSImageView *partnerLogo;
@property (weak) IBOutlet NSBox *logoDivider;
@property (weak) IBOutlet NSImageView *affectivaLogo;
@property (strong) AVCaptureSession *session;
@property dispatch_queue_t process_queue;
@property (weak) IBOutlet NSView *statsView;
@property (weak) IBOutlet NSTextField *fpsUnprocessedTextField;
@property (weak) IBOutlet NSTextField *resolution;
@property (weak) IBOutlet NSTextField *fpsProcessedTextField;
@property (weak) IBOutlet NSTextField *detectors;
@property (strong) AFDXDetector *detector;
@property (assign) BOOL drawFacePoints;
@property (assign) BOOL drawAppearanceIcons;
@property (assign) BOOL drawFrameRate;
@property (assign) BOOL drawFramesToScreen;
@property (assign) BOOL drawDominantEmoji;
@property (assign) BOOL drawFaceBox;
@property (assign) CGFloat pointSize;
@property (assign) CGFloat logoSize;
@property (assign) CGFloat logoOpacity;
@property (strong) NSMutableDictionary *faceMeasurements;
@property (weak) IBOutlet NSView *classifiersView;

@property (assign) CGFloat partnerLogoAspectRatio;
@property (assign) CGFloat affectivaLogoAspectRatio;

@property (assign) BOOL selectedClassifiersDirty;
@property (assign) IBOutlet NSButton *shareButton;

@property (strong) PreferencesWindowController *preferencesWindowController;

- (NSError *)startDetector;
- (NSError *)stopDetector;

@end
