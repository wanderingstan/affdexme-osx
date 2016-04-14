//
//  AffdexDemoViewController.m
//
//  Created by Affectiva on 2/22/13.
//  Copyright (c) 2016 Affectiva Inc.
//
//  See the file license.txt for copying permission.

#define YOUR_AFFDEX_LICENSE_STRING_GOES_HERE @"{\"token\": \"b898714e3fcc4d2ea6009e8b809932510b5a47b0b54fcaad6a8fd465e32452d8\", \"licensor\": \"Affectiva Inc.\", \"expires\": \"2026-01-28\", \"developerId\": \"iosdev@affectiva.com\", \"software\": \"Affdex SDK\"}"


#ifndef YOUR_AFFDEX_LICENSE_STRING_GOES_HERE
#error Please set the macro YOUR_AFFDEX_LICENSE_STRING_GOES_HERE to the contents of your Affectiva SDK license file.
#endif

#import "AffdexMeViewController.h"
#import "ClassifierModel.h"
#import "NSImage+Extensions.h"

//#define VIDEO_TEST

@interface AffdexMeViewController ()

@property (assign) NSTimeInterval timestampOfLastFrame;
@property (assign) NSTimeInterval timestampOfLastProcessedFrame;
@property (strong) NSDictionary *entries;
@property (strong) NSEnumerator *entryEnumerator;
@property (strong) NSDictionary *jsonEntry;
@property (strong) NSDictionary *videoEntry;
@property (strong) NSString *jsonFilename;
@property (strong) NSString *mediaFilename;

@property (strong) NSMutableArray *facePointsToDraw;
@property (strong) NSMutableArray *faceRectsToDraw;

@property (strong) NSArray *emotions;   // the array of dictionaries of all emotion classifiers
@property (strong) NSArray *expressions; // the array of dictionaries of all expression classifiers
@property (strong) NSArray *emojis; // the array of dictionaries of all emoji classifiers

@property (strong) NSMutableArray *classifiers;

@property (strong) NSImage *maleImage;
@property (strong) NSImage *femaleImage;
@property (strong) NSImage *unknownImage;
@property (strong) NSImage *maleImageWithGlasses;
@property (strong) NSImage *femaleImageWithGlasses;
@property (strong) NSImage *unknownImageWithGlasses;
@property (assign) CGRect genderRect;
@property (assign) AFDXCameraType cameraToUse;

@property (strong) NSArray *faces;

@property (assign) BOOL multifaceMode;
@property (strong) ExpressionViewController *dominantEmotionOrExpression;

@end

@implementation AffdexMeViewController

#pragma mark -
#pragma mark AFDXDetectorDelegate Methods

#ifdef VIDEO_TEST
- (void)detectorDidFinishProcessing:(AFDXDetector *)detector;
{
    [self stopDetector];
}
#endif

- (void)processedImageReady:(AFDXDetector *)detector
                      image:(NSImage *)image
                      faces:(NSDictionary *)faces
                     atTime:(NSTimeInterval)time;
{
    
    self.faces = [faces allValues];
    
    NSTimeInterval interval = time - self.timestampOfLastProcessedFrame;
    
    if (interval > 0)
    {
        float fps = 1.0 / interval;
        self.fpsProcessed.stringValue = [NSString stringWithFormat:@"FPS(P): %.1f", fps];
    }
    
    self.timestampOfLastProcessedFrame = time;
    
    // setup arrays of points and rects
    self.facePointsToDraw = [NSMutableArray new];
    self.faceRectsToDraw = [NSMutableArray new];

    // Handle each metric in the array
    for (AFDXFace *face in [faces allValues])
    {
        NSDictionary *faceData = face.userInfo;
        NSArray *viewControllers = [faceData objectForKey:@"viewControllers"];
        
        [self.facePointsToDraw addObjectsFromArray:face.facePoints];
        [self.faceRectsToDraw addObject:[NSValue valueWithRect:face.faceBounds]];

        // get dominant emoji
        [face.userInfo setObject:[NSNumber numberWithInt:face.emojis.dominantEmoji] forKey:@"dominantEmoji"];
        
        // check if selectedClassifiers is dirty -- if so, update classifier models associated with expression view controllers
        if (self.selectedClassifiersDirty == YES)
        {
            NSArray *selectedClassifiers = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedClassifiersKey];
            NSUInteger selectedClassifiersCount = [selectedClassifiers count];
            for (int i = 0; i < [viewControllers count]; i++)
            {
                ExpressionViewController *vc = [viewControllers objectAtIndex:i];
                if (i < selectedClassifiersCount)
                {
                    NSString *classifierName = [selectedClassifiers objectAtIndex:i];
                    ClassifierModel *model = [ClassifierModel modelWithName:classifierName];
                    [vc setClassifier:model];
                }
                else
                {
                    [vc setClassifier:nil];
                }
            }
        }
        
        // update scores
        for (ExpressionViewController *v in viewControllers)
        {
            NSString *scoreProperty = v.classifier.scoreProperty;
            if (nil != scoreProperty)
            {
                CGFloat score = [[face valueForKeyPath:scoreProperty] floatValue];
                if (!isnan(score))
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        v.metric = score;
                    });
                }
            }
        }
    }
    self.selectedClassifiersDirty = NO;
};

- (void)unprocessedImageReady:(AFDXDetector *)detector image:(NSImage *)image atTime:(NSTimeInterval)time;
{
    __block AffdexMeViewController *weakSelf = self;
    __block NSImage *newImage = image;
#ifdef DISPATCH_UNPROCESSED_FRAMES_ON_BLOCK
    dispatch_async(dispatch_get_main_queue(), ^{
#endif
        self.fps.hidden = !weakSelf.drawFrameRate;
        
        for (AFDXFace *face in self.faces) {
            NSRect faceBounds = face.faceBounds;
            //faceBounds.origin.y = self.view.bounds.size.height - faceBounds.origin.y;
            
            NSImage *genderImage = nil;
            switch (face.appearance.gender) {
                case AFDX_GENDER_MALE:
                    genderImage = self.maleImage;
                    if (face.appearance.glasses == AFDX_GLASSES_YES) {
                        genderImage = self.maleImageWithGlasses;
                    }
                    break;
                case AFDX_GENDER_FEMALE:
                    genderImage = self.femaleImage;
                    if (face.appearance.glasses == AFDX_GLASSES_YES) {
                        genderImage = self.femaleImageWithGlasses;
                    }
                    break;
                case AFDX_GENDER_UNKNOWN:
                    genderImage = self.unknownImage;
                    if (face.appearance.glasses == AFDX_GLASSES_YES) {
                        genderImage = self.unknownImageWithGlasses;
                    }
                    break;
            }

            // create array of images and rects to do all drawing at once
            NSMutableArray *imagesArray = [NSMutableArray array];
            NSMutableArray *rectsArray = [NSMutableArray array];
            
            // add dominant emoji
            if (weakSelf.drawDominantEmoji) {
                Emoji dominantEmoji = [[face.userInfo objectForKey:@"dominantEmoji"] intValue];
                if (dominantEmoji != AFDX_EMOJI_NONE) {
                    for (ClassifierModel *model in self.emojis) {
                        NSNumber *code = model.emojiCode;
                        if (dominantEmoji == [code intValue]) {
                            // match!
                            NSImage *emojiImage = model.image;
                            if (nil != emojiImage) {
                                // resize bounds to be relative in size to bounding box
                                CGSize size = emojiImage.size;
                                CGFloat aspectRatio = size.height / size.width;
                                size.width = faceBounds.size.width * .33;
                                size.height = size.width * aspectRatio;
                                
                                CGRect rect = CGRectMake(faceBounds.origin.x + faceBounds.size.width,
                                                         image.size.height - (faceBounds.origin.y) - (size.height),
                                                         size.width,
                                                         size.height);
                                [imagesArray addObject:emojiImage];
                                [rectsArray addObject:[NSValue valueWithRect:rect]];
                                break;
                            }
                        }
                    }
                }
            }

            if (weakSelf.drawAppearanceIcons) {
                // add gender image
                if (genderImage != nil) {
                    // resize bounds to be relative in size to bounding box
                    CGSize size = genderImage.size;
                    CGFloat aspectRatio = size.height / size.width;
                    size.width = faceBounds.size.width * .33;
                    size.height = size.width * aspectRatio;
                    
                    CGRect rect = CGRectMake(faceBounds.origin.x + faceBounds.size.width,
                                             image.size.height - (faceBounds.origin.y) - (faceBounds.size.height),
                                             size.width,
                                             size.height);
                    [imagesArray addObject:genderImage];
                    [rectsArray addObject:[NSValue valueWithRect:rect]];
                }

                // add dominant emotion/expression
                if (self.multifaceMode == TRUE) {
                    CGFloat dominantScore = -9999;
                    NSString *dominantName = @"NONAME";
                 
                    for (NSDictionary *d in self.emotions) {
                        NSString *name = [d objectForKey:@"name"];
                        CGFloat score = [[face valueForKeyPath:[d objectForKey:@"score"]] floatValue];
                        // don't allow valence as per Steve H's suggestion
                        if ([name isEqualToString:@"Valence"]) {
                            continue;
                        }
                        if (score > dominantScore) {
                            dominantScore = score;
                            dominantName = name;
                        }
                    }
                }
            }
            
            // do drawing here
            NSColor *faceBoundsColor = nil;
            
            if (face.emotions.valence >= 20)
            {
                faceBoundsColor = [NSColor greenColor];
            }
            else if (face.emotions.valence <= -20)
            {
                faceBoundsColor = [NSColor redColor];
            }
            else
            {
                faceBoundsColor = [NSColor whiteColor];
            }
            
            // Position expression views
            NSMutableArray *viewControllers = [face.userInfo objectForKey:@"viewControllers"];
            NSViewController *vc = [viewControllers objectAtIndex:0];
            CGFloat expressionFrameHeight = vc.view.frame.size.height;
            CGFloat expressionFrameIncrement = faceBounds.size.height / ([[[NSUserDefaults standardUserDefaults] objectForKey:MaxClassifiersShownKey] integerValue]);
            CGFloat nextY = image.size.height - faceBounds.origin.y - expressionFrameHeight;
            for (NSViewController *vc in viewControllers)
            {
                NSRect frame = vc.view.frame;
                frame.origin.x = faceBounds.origin.x - frame.size.width - 10.0;
                frame.origin.y = nextY;
                vc.view.frame = frame;
                NSImage *image = [NSImage imageFromView:vc.view];
                [imagesArray addObject:image];
                [rectsArray addObject:[NSValue valueWithRect:frame]];
                nextY -= expressionFrameIncrement;
            }
            
            newImage = [AFDXDetector imageByDrawingPoints:weakSelf.drawFacePoints ? weakSelf.facePointsToDraw : nil
                                        andRectangles:weakSelf.drawFaceBox ? weakSelf.faceRectsToDraw : nil
                                            andImages:imagesArray
                                           withRadius:self.pointSize
                                      usingPointColor:[NSColor whiteColor]
                                  usingRectangleColor:faceBoundsColor
                                      usingImageRects:rectsArray
                                              onImage:newImage];
        }

        // flip image if the front camera is being used so that the perspective is mirrored.
        if (self.cameraToUse == AFDX_CAMERA_FRONT) {
            NSImage *flippedImage = newImage;
            [weakSelf.imageView setImage:flippedImage];
        } else {
            [weakSelf.imageView setImage:newImage];
        }

        // compute frames per second and show
        NSTimeInterval interval = time - weakSelf.timestampOfLastFrame;
        
        if (interval > 0)
        {
            float fps = 1.0 / interval;
            if (time )
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.fps.stringValue = [NSString stringWithFormat:@"FPS(C): %.1f", fps];
                });
        }

        weakSelf.timestampOfLastFrame = time;
#ifdef DISPATCH_UNPROCESSED_FRAMES_ON_BLOCK
    });
#endif
    
#ifdef VIDEO_TEST
    static NSTimeInterval last = 0;
    const CGFloat timeConstant = 0.0000001;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:(time - last) * timeConstant]];
    last = time;
#endif
    
}

- (void)detector:(AFDXDetector *)detector hasResults:(NSMutableDictionary *)faces forImage:(NSImage *)image atTime:(NSTimeInterval)time;
{
    if (nil == faces)
    {
        [self unprocessedImageReady:detector image:image atTime:time];
    }
    else
    {
        [self processedImageReady:detector image:image faces:faces atTime:time];
    }
}

- (void)detector:(AFDXDetector *)detector didStartDetectingFace:(AFDXFace *)face;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *viewControllers = [NSMutableArray array];

        NSUInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:MaxClassifiersShownKey] integerValue];
        for (int i = 0; i < count; i++)
        {
            ExpressionViewController *vc = [[ExpressionViewController alloc] initWithClassifier:nil];
            [viewControllers addObject:vc];
//            [self.view addSubview:vc.view];
        }
        
        NSArray *selectedClassifiers = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedClassifiersKey];
        count = [selectedClassifiers count];
        for (int i = 0; i < count; i++)
        {
            NSString *classifierName = [selectedClassifiers objectAtIndex:i];
            ClassifierModel *model = [ClassifierModel modelWithName:classifierName];
            ExpressionViewController *vc = [viewControllers objectAtIndex:i];
            [vc setClassifier:model];
        }

        face.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:viewControllers, @"viewControllers",
                                [NSNumber numberWithInt:AFDX_EMOJI_NONE], @"dominantEmoji",
                                nil];
    });
}

- (void)detector:(AFDXDetector *)detector didStopDetectingFace:(AFDXFace *)face;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *viewControllers = [face.userInfo objectForKey:@"viewControllers"];
        for (ExpressionViewController *vc in viewControllers)
        {
            vc.metric = 0.0;
            [vc.view removeFromSuperview];
        }
        
        face.userInfo = nil;
    });
}


#pragma mark -
#pragma mark ViewController Delegate Methods

+ (void)initialize;
{
    AVCaptureDevice *firstDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    if (nil != firstDevice)
    {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{SelectedCameraKey : [firstDevice localizedName]}];
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{FacePointsKey : [NSNumber numberWithBool:YES]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{FaceBoxKey : [NSNumber numberWithBool:YES]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{PointSizeKey : [NSNumber numberWithFloat:2.0]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{DrawDominantEmojiKey : [NSNumber numberWithBool:YES]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{DrawAppearanceIconsKey : [NSNumber numberWithBool:YES]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{DrawFrameRateKey : [NSNumber numberWithBool:NO]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ProcessRateKey : [NSNumber numberWithFloat:10.0]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{SelectedClassifiersKey : [NSMutableArray arrayWithObjects:@"anger", @"joy", @"sadness", @"disgust", @"surprise", @"fear", nil]}];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{MaxClassifiersShownKey : [NSNumber numberWithInteger:6]}];
}

-(BOOL)canBecomeFirstResponder;
{
    return YES;
}

- (void)dealloc;
{
    self.detector = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.cameraToUse = AFDX_CAMERA_FRONT;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"male-noglasses" ofType:@"png" inDirectory:@"media"];
    self.maleImage = [[NSImage alloc] initWithContentsOfFile:path];

    path = [[NSBundle mainBundle] pathForResource:@"female-noglasses" ofType:@"png" inDirectory:@"media"];
    self.femaleImage = [[NSImage alloc] initWithContentsOfFile:path];

    path = [[NSBundle mainBundle] pathForResource:@"male-glasses" ofType:@"png" inDirectory:@"media"];
    self.maleImageWithGlasses = [[NSImage alloc] initWithContentsOfFile:path];

    path = [[NSBundle mainBundle] pathForResource:@"female-glasses" ofType:@"png" inDirectory:@"media"];
    self.femaleImageWithGlasses = [[NSImage alloc] initWithContentsOfFile:path];

    path = [[NSBundle mainBundle] pathForResource:@"unknown-noglasses" ofType:@"png" inDirectory:@"media"];
    self.unknownImage = [[NSImage alloc] initWithContentsOfFile:path];

    path = [[NSBundle mainBundle] pathForResource:@"unknown-glasses" ofType:@"png" inDirectory:@"media"];
    self.unknownImageWithGlasses = [[NSImage alloc] initWithContentsOfFile:path];

    self.emotions = [ClassifierModel emotions];
    self.expressions = [ClassifierModel expressions];
    self.emojis = [ClassifierModel emojis];
    
#if 0
    self.selectedClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:@"classifiers"] mutableCopy];
    if (self.selectedClassifiers == nil)
    {
        self.selectedClassifiers = [NSMutableArray arrayWithObjects:@"anger", @"contempt", @"disgust", @"fear", @"joy", @"sadness", nil];
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedClassifiers forKey:@"classifiers"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
#endif

    [self.shareButton setImage:[NSImage imageNamed:NSImageNameShareTemplate]];
    [self.shareButton sendActionOn:NSLeftMouseDownMask];
}

- (void)viewWillDisappear;
{
    // remove ourself as an observer
    [[NSUserDefaults standardUserDefaults] removeObserver:self
                                            forKeyPath:SelectedCameraKey];
    
    [self stopDetector];
    
    [self resignFirstResponder];
    
    [super viewWillDisappear];
}

- (void)viewWillAppear;
{
    [super viewWillAppear];
    
    [self.imageView setImage:nil];
    
    NSMutableArray *selectedClassifers = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedClassifiersKey];
    NSUInteger count = [selectedClassifers count];
    
    for (NSUInteger i = 0; i < count; i++)
    {
        ClassifierModel *m = [ClassifierModel modelWithName:[selectedClassifers objectAtIndex:0]];
        
        [self.classifiers addObject:m];
    }
    
    for (ClassifierModel *m in self.emotions)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:m.enabled] forKey:m.name];
    }

    // add ourself as an observer of various settings
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:SelectedCameraKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)SelectedCameraKey];
}

- (void)viewDidAppear;
{
    [super viewDidAppear];
    [self becomeFirstResponder];
#ifdef VIDEO_TEST
    self.mediaFilename = [[NSBundle mainBundle] pathForResource:@"face1" ofType:@"mov"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.mediaFilename] == YES)
    {
        [self startDetector];
    }
#endif
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == (__bridge void *)SelectedCameraKey)
    {
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self stopDetector];
        NSError *error = [self startDetector];
        if (nil != error)
        {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
            
            [NSApp terminate:self];
        }
        
        return;
    }

    id v = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([v isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if (context == (__bridge void *)FacePointsKey)
    {
        BOOL value = [v boolValue];
        
        self.drawFacePoints = value;
    }
    else
    if (context == (__bridge void *)FaceBoxKey)
    {
        BOOL value = [v boolValue];
        
        self.drawFaceBox = value;
    }
    else
    if (context == (__bridge void *)DrawDominantEmojiKey)
    {
        BOOL value = [v boolValue];
            
        self.drawDominantEmoji = value;
    }
    else
    if (context == (__bridge void *)DrawAppearanceIconsKey)
    {
        BOOL value = [v boolValue];
        
        self.drawAppearanceIcons = value;
    }
    else
    if (context == (__bridge void *)DrawFrameRateKey)
    {
        BOOL value = [v boolValue];
        
        self.drawFrameRate = value;
    }
    else
    if (context == (__bridge void *)PointSizeKey)
    {
        CGFloat value = [v floatValue];
        
        self.pointSize = value;
    }
    else
    if (context == (__bridge void *)ProcessRateKey)
    {
        CGFloat value = [v floatValue];
        
        self.detector.maxProcessRate = value;
    }
    else
    {
        self.selectedClassifiersDirty = TRUE;
    }
}

- (NSError *)startDetector;
{
    NSError *result = nil;
    
    [self.detector stop];
    
    NSUInteger maximumFaces = 10;

    // create our detector with our desired facial expresions, using the front facing camera
    
    NSString *localizedName = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedCameraKey];
    
    AVCaptureDevice *device = nil;
    
    for (device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
        if ([[device localizedName] isEqualToString:localizedName])
        {
            break;
        }
    }
    
    if (nil == device)
    {
        device = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    }
    
#ifdef VIDEO_TEST
    // create our detector with our desired facial expresions, using the front facing camera
    self.detector = [[AFDXDetector alloc] initWithDelegate:self usingFile:self.mediaFilename maximumFaces:maximumFaces];
#else
    // create our detector with our desired facial expresions, using the front facing camera
    self.detector = [[AFDXDetector alloc] initWithDelegate:self usingCaptureDevice:device maximumFaces:maximumFaces];
#endif
    
    // add ourself as an observer of various settings
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:FacePointsKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)FacePointsKey];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:FaceBoxKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)FaceBoxKey];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:PointSizeKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)PointSizeKey];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:ProcessRateKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)ProcessRateKey];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:DrawDominantEmojiKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)DrawDominantEmojiKey];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:DrawAppearanceIconsKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)DrawAppearanceIconsKey];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:DrawFrameRateKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(__bridge void *)DrawFrameRateKey];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:SelectedClassifiersKey
                                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                               context:(void *)SelectedClassifiersKey];
    
    for (NSString *name in [[NSUserDefaults standardUserDefaults] objectForKey:SelectedClassifiersKey])
    {
        ClassifierModel *m = [ClassifierModel modelWithName:name];
        
        if (m.enabled == TRUE)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:m.name];
        }
    }
    
    NSInteger maxProcessRate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"maxProcessRate"] integerValue];
    if (0 == maxProcessRate)
    {
        maxProcessRate = 10;
    }
    
    self.detector.maxProcessRate = maxProcessRate;
    self.timestampOfLastFrame = 0;
    self.timestampOfLastProcessedFrame = 0;
    self.detector.licenseString = YOUR_AFFDEX_LICENSE_STRING_GOES_HERE;
    
    // tell the detector which facial expressions we want to measure
    [self.detector setDetectAllEmotions:YES];
    [self.detector setDetectAllExpressions:YES];
    [self.detector setDetectEmojis:YES];
    self.detector.gender = TRUE;
    self.detector.glasses = TRUE;
    
    // let's start it up!
    result = [self.detector start];
    if (nil == result)
    {
    }
    
    return result;
}

- (NSError *)stopDetector;
{
    NSError *result = nil;
    
    if (self.detector != nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:DrawFrameRateKey];
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:DrawAppearanceIconsKey];
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:DrawDominantEmojiKey];
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:SelectedClassifiersKey];
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:FacePointsKey];
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:FaceBoxKey];
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:PointSizeKey];
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:ProcessRateKey];
        
        result = [self.detector stop];
    }
    
    return result;
}

// Closing the main window will terminate the app
- (void)windowWillClose:(NSNotification *)notification;
{
    [NSApp terminate:self];
}

// This method activates the Preferences window
- (IBAction)showPreferencesWindow:(id)sender
{
    if (nil == self.preferencesWindowController)
    {
        self.preferencesWindowController = [[PreferencesWindowController alloc] init];
    }
    
    [self.preferencesWindowController showWindow:self];
}

- (IBAction)shareButtonAction:(id)sender;
{
    [self.shareButton setHidden:TRUE];
    NSImage *image = [NSImage imageFromView:self.view];
    [self.shareButton setHidden:FALSE];
    NSSharingServicePicker *sharingServicePicker = [[NSSharingServicePicker alloc] initWithItems:@[image]];
    sharingServicePicker.delegate = self;
    
    [sharingServicePicker showRelativeToRect:[sender bounds]
                                      ofView:sender
                               preferredEdge:NSMinYEdge];
}

- (void)showHelp:(id)sender;
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com/Affectiva/affdexme-osx"]];
}

@end
