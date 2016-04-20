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

@interface MyCollectionView : NSCollectionView

@end

@implementation MyCollectionView

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
            NSCollectionViewItem *anItem = [self itemAtIndex:ctr];
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

@implementation ClassifierViewItem

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear
{
    // seems the inital selection state is not done by Apple in a KVO compliant manner, update manually
    [self updateSelectionState:self.isSelected];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2; //set how many pixels the shadow has
    shadow.shadowOffset = NSMakeSize(0, 0); //the distance from the text the shadow is dropped
    shadow.shadowColor = [NSColor blackColor];
    self.textField.shadow = shadow;
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
        self.textField.textColor = [NSColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0];
        self.textField.font = [NSFont fontWithName:@"Arial Bold" size:18];
        NSRect frame = self.textField.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        self.textField.frame = frame;
        [self.imageView.layer setOpacity:1.0];;
        [self.imageView.layer setBorderColor:[[NSColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0] CGColor]];
        [self.imageView.layer setBorderWidth:3.0];
    }
    else
    {
        self.textField.textColor = [NSColor whiteColor];
        self.textField.font = [NSFont fontWithName:@"Arial Bold" size:16];
        NSRect frame = self.textField.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        self.textField.frame = frame;
        [self.imageView.layer setOpacity:0.8];;
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