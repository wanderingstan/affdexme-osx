//
//  ClassifierPickerViewController.m
//  AffdexMe
//
//  Created by boisy on 8/18/15.
//  Copyright (c) 2016 Affectiva Inc.
//
//  See the file license.txt for copying permission.

#import "ClassifierPickerViewController.h"
//#import "HeaderCollectionReusableView.h"
#import "AffdexMeViewController.h"
#import "ClassifierModel.h"

@interface CustomTextField : NSTextField
@end

@implementation CustomTextField

static NSMutableDictionary *regularAttributes = nil;
static NSMutableDictionary *indesignBackgroundAttributes = nil;
static NSMutableDictionary *indesignForegroundAttributes = nil;

- (void)drawRect:(NSRect)frame;
{
    NSString *string = self.stringValue;
    
    if (regularAttributes == nil) {
        regularAttributes = [NSMutableDictionary
                              dictionaryWithObjectsAndKeys:
                             [NSFont fontWithName:@"Arial Black" size:15.0], NSFontAttributeName,
                              [NSColor whiteColor],NSForegroundColorAttributeName,
                              [NSNumber numberWithFloat:-5.0],NSStrokeWidthAttributeName,
                              [NSColor blackColor],NSStrokeColorAttributeName, nil];
    }
    
    if (indesignBackgroundAttributes == nil) {
        indesignBackgroundAttributes = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:
                                        [NSFont fontWithName:@"Arial Black" size:15.0], NSFontAttributeName,
                                         [NSNumber numberWithFloat:-15.0],NSStrokeWidthAttributeName,
                                         [NSColor blackColor],NSStrokeColorAttributeName, nil];
    }
    
    if (indesignForegroundAttributes == nil) {
        indesignForegroundAttributes = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:
                                        [NSFont fontWithName:@"Arial Black" size:15.0], NSFontAttributeName,
                                         [NSColor whiteColor],NSForegroundColorAttributeName, nil];
    }
    
    [[NSColor clearColor] set];
    [NSBezierPath fillRect:frame];
    
    // draw top string
    NSSize size = [string sizeWithAttributes:indesignBackgroundAttributes];
    NSPoint p = NSMakePoint((frame.origin.x + frame.size.width - size.width) / 2, 0);
    
    [string drawAtPoint:p withAttributes:regularAttributes];
    
    // draw bottom string in two passes
    [string drawAtPoint:p withAttributes:indesignBackgroundAttributes];
    [string drawAtPoint:p withAttributes:indesignForegroundAttributes];
}

@end

@interface ClassifierCollectionViewItem : NSCollectionViewItem

@property (strong) NSTrackingArea *trackingArea;
@property (strong) AVPlayer *player;
@property (strong) AVPlayerLayer *playerLayer;

- (void)playMovie;

@end

@interface ClassifierCollectionView : NSCollectionView

@end

@implementation ClassifierCollectionView

// Ignore key events for this view
- (void)keyDown:(NSEvent *)theEvent;
{
    return;
}

- (void)keyUp:(NSEvent *)theEvent;
{
    return;
}

- (void)mouseDown:(NSEvent *)originalEvent;
{
    NSUInteger maxClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:kMaxClassifiersShownKey] integerValue];
    BOOL maximumItemsSelected = [[self selectionIndexes] count] == maxClassifiers;

    NSPoint mouseDownPoint = [self convertPoint:[originalEvent locationInWindow] fromView:nil];

    for (NSUInteger ctr = 0; ctr < [self.content count]; ctr++)
    {
        NSRect aFrame = [self frameForItemAtIndex:ctr];
        if ([self mouse:mouseDownPoint inRect:aFrame])
        {
            ClassifierCollectionViewItem *anItem = (ClassifierCollectionViewItem *)[self itemAtIndex:ctr];
            [anItem playMovie];
            ClassifierModel *m = [anItem representedObject];
            if (m.enabled == FALSE && maximumItemsSelected)
            {
                // early return here IF maxClassifiers is selected and the user
                // is about to select maxClassifiers+1
                return;
            }

            NSMutableArray *selectedClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedClassifiersKey] mutableCopy];

            m.enabled = !m.enabled;
            [anItem setSelected:m.enabled];
            if (m.enabled == FALSE)
            {
                [selectedClassifiers removeObject:m.name];
            }
            else
            {
                [selectedClassifiers addObject:m.name];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:selectedClassifiers forKey:kSelectedClassifiersKey];
            
            break;
        }
    }

    return;
}

@end

@implementation ClassifierCollectionViewItem

- (void)playMovie;
{
    ClassifierModel *m = [self representedObject];
    self.player = [[AVPlayer alloc] initWithURL:m.movieURL];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playerLayer setFrame:self.view.bounds];
    [self.imageView setWantsLayer:YES];
    [self.imageView.layer addSublayer:self.playerLayer];
    [self.player play];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
//    [self.imageView.layer addSublayer:self.playerLayer];
//    [self.player play];
    
    return;
}

- (void)mouseExited:(NSEvent *)theEvent
{
//    [self.player pause];
//    [self.playerLayer removeFromSuperlayer];
    ClassifierModel *m = [self representedObject];
    NSLog(@"Exiting %@", m.name);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear
{
    // seems the inital selection state is not done by Apple in a KVO compliant manner, update manually
    [self updateSelectionState:self.isSelected];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 1.25; //set how many pixels the shadow has
    shadow.shadowOffset = NSMakeSize(0, 0); //the distance from the text the shadow is dropped
    shadow.shadowColor = [NSColor blackColor];
//    self.textField.shadow = shadow;
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.frame
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                  owner:self userInfo:nil];
//    NSLog(@"Tracking %@", NSStringFromRect(self.view.frame));
    [self.view addTrackingArea:self.trackingArea];

    
    ClassifierModel *m = [self representedObject];
}

- (void)updateSelectionState:(BOOL)flag
{
    // assign a layer at this time
    if (self.view.layer == nil)
    {
        self.view.layer = [CALayer new];
        self.view.wantsLayer = YES;
    }

    if (flag)
    {
        [self.imageView.layer setBorderColor:[[NSColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0] CGColor]];
        [self.imageView.layer setBorderWidth:5.0];
    }
    else
    {
        [self.imageView.layer setBorderColor:[[NSColor blackColor] CGColor]];
        [self.imageView.layer setBorderWidth:0.0];
    }
}

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    [self updateSelectionState:flag];
}

- (NSColor *)textColor
{
    return self.selected ? [NSColor whiteColor] : [NSColor textColor];
}

@end

@implementation ClassifierPickerViewController

- (void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualTo:@"selectionIndexes"])
    {
        NSUInteger count = [[self.arrayController selectedObjects] count];
        NSUInteger maxClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:kMaxClassifiersShownKey] integerValue];
        
        if (count > 0)
        {
            self.instructionLabel.stringValue = [NSString stringWithFormat:@"%ld out of %ld classifiers selected", count,
                                                     maxClassifiers];
        }
        else
        {
            self.instructionLabel.stringValue = [NSString stringWithFormat:@"Select up to %ld classifiers.", maxClassifiers];
        }
    }
    else if (keyPath == kSelectedClassifiersKey)
    {
    }
}

- (void)viewWillDisappear;
{
    [super viewWillDisappear];
    [self.arrayController removeObserver:self
                              forKeyPath:@"selectionIndexes"];
    
    [[NSUserDefaults standardUserDefaults] removeObserver:self
                                               forKeyPath:kSelectedClassifiersKey];
}

- (NSArray *)classifierArray;
{
    NSArray *emotions = [ClassifierModel emotions];
    NSArray *expressions = [ClassifierModel expressions];
    return [emotions arrayByAddingObjectsFromArray:expressions];
}

- (void)viewWillAppear;
{
    [super viewWillAppear];

    [self.arrayController addObserver:self
                           forKeyPath:@"selectionIndexes"
                              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                              context:nil];

    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kSelectedClassifiersKey
                                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                                context:(void *)kSelectedClassifiersKey];

    for (NSString *classifierName in [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedClassifiersKey])
    {
        NSUInteger numberOfItems = [[self.collectionView content] count];
        for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++)
        {
            NSCollectionViewItem *item = [self.collectionView itemAtIndex:itemIndex];
            ClassifierModel *m = [item representedObject];
            if ([[m valueForKey:@"name"] isEqualToString:classifierName] == YES)
//            if ([m.name isEqualToString:classifierName] == YES)
            {
                m.enabled = TRUE;
                item.selected = TRUE;
            }
        }
    }
}

- (void)clearAllButtonClicked;
{
    [self.arrayController setSelectionIndexes:[NSIndexSet new]];
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kSelectedClassifiersKey];

    NSUInteger numberOfItems = [[self.collectionView content] count];
    for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++)
    {
        NSCollectionViewItem *item = [self.collectionView itemAtIndex:itemIndex];
        ClassifierModel *m = [item representedObject];
        m.enabled = FALSE;
    }
}

- (void)resetDefaultsButtonClicked;
{
    NSArray *defaults = @[@"anger", @"joy", @"sadness", @"disgust", @"surprise", @"fear"];
    
    [self.arrayController setSelectionIndexes:[NSIndexSet new]];
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kSelectedClassifiersKey];

    NSUInteger numberOfItems = [[self.collectionView content] count];
    for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++)
    {
        NSCollectionViewItem *item = [self.collectionView itemAtIndex:itemIndex];
        ClassifierModel *m = [item representedObject];
        m.enabled = FALSE;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:defaults forKey:kSelectedClassifiersKey];

    NSMutableIndexSet *set = [NSMutableIndexSet new];

    for (NSString *d in defaults)
    {
        ClassifierModel *m = [ClassifierModel modelWithName:d];
        m.enabled = TRUE;
        
        NSUInteger count = [[self.arrayController arrangedObjects] count];

        for (int i = 0; i < count; i++)
        {
            ClassifierModel *m = [[self.arrayController arrangedObjects] objectAtIndex:i];
            
            if ([m.name isEqualToString:d])
            {
                [set addIndex:i];
            }
        }
    }

    [self.arrayController setSelectionIndexes:set];
}

@end