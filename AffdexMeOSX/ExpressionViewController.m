//
//  ExpressionViewController.m
//  AffdexMe
//
//  Created by Boisy Pitre on 2/14/14.
//  Copyright (c) 2014 Affectiva. All rights reserved.
//

#import "ExpressionViewController.h"

@interface ExpressionViewController ()

@property (assign) CGRect indicatorBounds;

@end

@implementation CustomLevelIndicator

- (void)drawRect:(NSRect)theRect
{
    NSRect fillingRect = theRect;
    fillingRect.size.width = theRect.size.width * fabs(self.percent) / 100.0;
    NSColor *indicatorColor;
    
    if (self.percent >= 0)
    {
        indicatorColor = [NSColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0];
    }
    else
    {
        indicatorColor = [NSColor redColor];
    }
    
    [indicatorColor set];
    
    NSRectFill(fillingRect);
}

- (void)setPercentage:(CGFloat)inPercent
{
    self.percent = inPercent;
    [self setNeedsDisplay:YES];
}

@end

@implementation ExpressionViewController

@dynamic metric;
@synthesize classifier = _classifier;

- (ClassifierModel *)classifier;
{
    return _classifier;
}

- (void)setClassifier:(ClassifierModel *)classifier;
{
    _classifier = classifier;
    if (_classifier == nil)
    {
        self.expressionLabel.stringValue = @"";
        self.indicatorView.hidden = TRUE;
    }
    else
    {
        self.expressionLabel.stringValue = _classifier.title;
        self.indicatorView.hidden = FALSE;
    }
}

- (id)initWithClassifier:(ClassifierModel *)classifier;
{
    self = [super initWithNibName:@"ExpressionView" bundle:nil];

    if (self)
    {
        self.classifier = classifier;
    }
    
    return self;
}

- (void)reset;
{
//    self.view.alpha = 0.0;
}

- (void)viewDidLoad;
{
    CGFloat labelSize = self.expressionLabel.font.pointSize;
    CGFloat scoreSize = self.scoreLabel.font.pointSize;
    
    self.expressionLabel.font = [NSFont fontWithName:@"SquareFont" size:labelSize];
    self.expressionLabel.backgroundColor = [NSColor clearColor];

    [self setClassifier:self.classifier];

    self.scoreLabel.font = [NSFont fontWithName:@"SquareFont" size:scoreSize];
    
    self.indicatorBounds = self.indicatorView.bounds;
    [self setMetric:0.0 animated:NO];
    self.view.wantsLayer = YES;
}

- (float)metric;
{
    return self.metric;
}

- (void)setMetric:(float)metric;
{
    [self setMetric:metric animated:YES];
}

- (void)setMetric:(float)value animated:(BOOL)animated;
{
    if (!isnan(value))
    {
        CGRect bounds = self.indicatorBounds;
        if (isnan(value))
        {
            bounds.size.width = 0.0;
        }
        else
        {
            bounds.size.width *= (value / 100.0);
        }
        
        [self.indicatorView setPercentage:value];
        
        self.scoreLabel.stringValue = [NSString stringWithFormat:@"%.0f%%", value];

        if (fabs(value) > 1.0)
        {
            self.expressionLabel.textColor = [NSColor blackColor];
        }
        else
        {
            self.expressionLabel.textColor = [NSColor whiteColor];
        }
    }
}

- (void)faceDetected;
{
}

- (void)faceUndetected;
{
//    [NSView beginAnimations:nil context:NULL];
//    [NSView setAnimationDuration:0.25];
    self.view.alphaValue = 0.0;
//    [NSView commitAnimations];
}

@end
