//
//  ExpressionViewController.h
//  AffdexMe
//
//  Created by Boisy Pitre on 2/14/14.
//  Copyright (c) 2014 Affectiva. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClassifierModel.h"

@interface CustomLevelIndicator : NSLevelIndicator
{
}

@property (assign) CGFloat percent;

@end

@interface ExpressionViewController : NSViewController

@property (strong) IBOutlet NSTextField *expressionLabel;
@property (strong) IBOutlet NSTextField *scoreLabel;
@property (strong) IBOutlet CustomLevelIndicator *indicatorView;
@property (assign) float metric;
@property (strong) ClassifierModel *classifier;

- (id)initWithClassifier:(ClassifierModel *)classifier;
- (void)faceDetected;
- (void)faceUndetected;
- (void)reset;

@end
