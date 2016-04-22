//
//  PreferencesWindowController.h
//  WeatherSnoop
//
//  Created by Boisy Pitre on 3/11/13.
//  Copyright (c) 2013 Boisy Pitre. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClassifierPickerViewController.h"

static NSString *kSelectedClassifiersKey = @"selectedClassifierList";
static NSString *kMaxClassifiersShownKey = @"maxClassifiersShown";

@interface PreferencesWindowController : NSWindowController

@property (assign) IBOutlet NSView *settingsView;
@property (assign) IBOutlet NSView *classifiersView;
@property (assign) IBOutlet NSToolbar *toolbar;
@property (strong) NSString *lastSelectedToolbarItemIdentifier;
@property (strong) IBOutlet NSView *containerView;

@property (strong) NSIndexSet *selectedIndexes;
@property (strong) IBOutlet NSTextField *selectionMessageTextField;
@property (strong) IBOutlet ClassifierPickerViewController *classifierPickerViewController;
@property (strong) NSString *selectedCameraDevice;

@end
