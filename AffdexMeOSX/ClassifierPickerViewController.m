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

- (void)mouseDown:(NSEvent *)originalEvent;
{
    NSUInteger maxClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:MaxClassifiersShownKey] integerValue];
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
            
            NSMutableArray *selectedClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:SelectedClassifiersKey] mutableCopy];

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
            
            [[NSUserDefaults standardUserDefaults] setObject:selectedClassifiers forKey:SelectedClassifiersKey];
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
    
    self.view.wantsLayer = YES;
}

- (void)viewDidAppear
{
    // seems the inital selection state is not done by Apple in a KVO compliant manner, update background color manually
    [self updateBackgroundColorForSelectionState:self.isSelected];
}

- (void)updateBackgroundColorForSelectionState:(BOOL)flag
{
    if (flag)
    {
        self.view.layer.backgroundColor = [[NSColor greenColor] CGColor];
    }
    else
    {
        self.view.layer.backgroundColor = [[NSColor clearColor] CGColor];
    }
}

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    [self updateBackgroundColorForSelectionState:flag];
}

- (NSColor *)textColor
{
    return self.selected ? [NSColor whiteColor] : [NSColor textColor];
}

@end

@implementation ClassifierPickerViewController

#define SELECTED_COLOR [NSColor greenColor]
#define SELECTED_TEXT_COLOR [NSColor blackColor]
#define UNSELECTED_COLOR [NSColor whiteColor]
#define UNSELECTED_TEXT_COLOR [NSColor blackColor]
#define ERROR_COLOR [NSColor redColor]
#define ERROR_TEXT_COLOR [NSColor whiteColor]

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualTo:@"selectionIndexes"])
    {
        NSUInteger count = [[self.arrayController selectedObjects] count];
        NSUInteger maxClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:MaxClassifiersShownKey] integerValue];
        
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
    else if (keyPath == SelectedClassifiersKey)
    {
    }
}

- (void)viewWillAppear;
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:[ClassifierModel emotions]];
    [array addObjectsFromArray:[ClassifierModel expressions]];
    [self setClassifierArray:array];
    
    [self.arrayController addObserver:self
                           forKeyPath:@"selectionIndexes"
                              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                              context:nil];

    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:SelectedClassifiersKey
                                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                                context:(void *)SelectedClassifiersKey];
    
    for (NSString *classifierName in [[NSUserDefaults standardUserDefaults] objectForKey:SelectedClassifiersKey])
    {
        NSUInteger numberOfItems = [[self.collectionView content] count];
        for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++)
        {
            NSCollectionViewItem *item = [self.collectionView itemAtIndex:itemIndex];
            ClassifierModel *m = [item representedObject];
            if ([m.name isEqualToString:classifierName] == YES)
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
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:SelectedClassifiersKey];

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
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:SelectedClassifiersKey];
    
    NSUInteger numberOfItems = [[self.collectionView content] count];
    for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++)
    {
        NSCollectionViewItem *item = [self.collectionView itemAtIndex:itemIndex];
        ClassifierModel *m = [item representedObject];
        m.enabled = FALSE;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:defaults forKey:SelectedClassifiersKey];

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