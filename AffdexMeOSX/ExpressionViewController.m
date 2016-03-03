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

@implementation ExpressionViewController

@dynamic metric;

- (id)initWithName:(NSString *)name;
{
    self = [super initWithNibName:@"ExpressionView" bundle:nil];

    if (self)
    {
        self.name = name;
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

    self.expressionLabel.stringValue = self.name;

    self.scoreLabel.font = [NSFont fontWithName:@"SquareFont" size:scoreSize];
    
    self.indicatorBounds = self.indicatorView.bounds;
    [self setMetric:0.0 animated:NO];
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
        
        CALayer *viewLayer = [self.indicatorView layer];

        if (value < 0.0)
        {
            [viewLayer setBackgroundColor:[[NSColor redColor] CGColor]];
        }
        else
        {
            [viewLayer setBackgroundColor:[[NSColor greenColor] CGColor]];
        }

        if (animated)
        {
//            [NSView beginAnimations:nil context:NULL];
        }

        [self.indicatorView setBounds:bounds];
        self.scoreLabel.stringValue = [NSString stringWithFormat:@"%.0f%%", value];
        float alphaValue = fmax(fabs(value) / 100.0, 0.35);
#if TARGET_OS_IPHONE
        self.view.alpha = alphaValue;
#else
        self.view.alphaValue = alphaValue;
#endif
        
        if (animated)
        {
//            [NSView setAnimationDuration:0.25];
//            [NSView commitAnimations];
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
#if TARGET_OS_IPHONE
    self.view.alpha = 0.0;
#else
    self.view.alphaValue = 0.0;
#endif
//    [NSView commitAnimations];
}

@end
