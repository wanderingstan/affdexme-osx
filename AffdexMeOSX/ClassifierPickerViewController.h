//
//  ClassifierPickerViewController.h
//  AffdexMe
//
//  Created by boisy on 8/18/15.
//  Copyright (c) 2016 Affectiva Inc.
//
//  See the file license.txt for copying permission.

#import <AppKit/AppKit.h>

@interface ClassifierPickerViewController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (weak) IBOutlet NSCollectionView *collectionView;
@property (strong) NSArray *availableClassifiers;
@property (strong) NSMutableArray *selectedClassifiers;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTextField *instructionLabel;
@property (weak) IBOutlet NSArrayController *arrayController;

@end
