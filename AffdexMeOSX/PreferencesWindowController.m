//
//  PreferencesWindowController.m
//  WeatherSnoop
//
//  Created by Boisy Pitre on 3/11/13.
//  Copyright (c) 2013 Boisy Pitre. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "ClassifierModel.h"
#import <AVFoundation/AVFoundation.h>

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

#define kLastPreferencesToolbarItemSelected @"LastPreferencesToolbarItemSelected"

+ (void)initialize;
{
    // register some sensible default values here...
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Settings", kLastPreferencesToolbarItemSelected,
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)init;
{
	if (self = [super initWithWindowNibName:@"PreferencesWindow"])
    {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)awakeFromNib;
{
    self.lastSelectedToolbarItemIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kLastPreferencesToolbarItemSelected];

    [self.toolbar setSelectedItemIdentifier:self.lastSelectedToolbarItemIdentifier];
    
    if (nil != self.lastSelectedToolbarItemIdentifier)
    {
        NSString *selectorString = [NSString stringWithFormat:@"show%@View:", self.lastSelectedToolbarItemIdentifier];
        [self performSelector:NSSelectorFromString(selectorString) withObject:nil];
    }
}

- (void)resizeView:(NSView *)theContainerView inWindow:(NSWindow *)window toAccomodate:(NSView *)viewToAdd;
{
    CGFloat adjustToTop = 0;
    
    // remove old view
    NSView *viewToRemove = nil;
    if ([[theContainerView subviews] count] > 0)
    {
        viewToRemove = [[self.containerView subviews] objectAtIndex:0];
        adjustToTop = viewToRemove.frame.size.height - viewToAdd.frame.size.height;
    }
    [viewToRemove removeFromSuperview];
    
    // resize frame to viewToAdd view
    NSRect containerViewFrame = [self.containerView frame];
    NSRect windowFrame = [window frame];
    NSRect newFrame = windowFrame;
    newFrame.size.height = windowFrame.size.height - containerViewFrame.size.height + viewToAdd.frame.size.height;
    newFrame.origin.y += adjustToTop;
    
    [window setFrame:newFrame display:YES animate:YES];
    
    [theContainerView addSubview:viewToAdd];
}

- (IBAction)showSettingsView:(id)sender;
{
	[self.toolbar setSelectedItemIdentifier:@"Settings"];
    [self resizeView:self.containerView inWindow:self.window toAccomodate:self.settingsView];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Settings" forKey:kLastPreferencesToolbarItemSelected];
}

- (IBAction)showClassifiersView:(id)sender;
{
    [self.toolbar setSelectedItemIdentifier:@"Classifiers"];
    [self resizeView:self.containerView inWindow:self.window toAccomodate:self.classifiersView];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Classifiers" forKey:kLastPreferencesToolbarItemSelected];
}

- (NSArray *)deviceArray;
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    NSMutableArray *deviceNames = [NSMutableArray array];
    for (AVCaptureDevice *device in devices)
    {
        [deviceNames addObject:device.localizedName];
    }
    
//    NSLog(@"Device Names: %@", deviceNames);

    return deviceNames;
}

@end
