//
//  ExpressionViewController.h
//  AffdexMe
//
//  Created by Boisy Pitre on 2/14/14.
//  Copyright (c) 2014 Affectiva. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ExpressionViewController : NSViewController

@property (strong) IBOutlet NSTextField *expressionLabel;
@property (strong) IBOutlet NSTextField *scoreLabel;
@property (strong) IBOutlet NSView *indicatorView;
@property (strong) NSString *name;
@property (assign) float metric;

- (id)initWithName:(NSString *)name;
- (void)faceDetected;
- (void)faceUndetected;
- (void)reset;

@end
