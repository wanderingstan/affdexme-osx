//
//  NSImage+Extensions.h
//  AffdexMe
//
//  Created by Boisy Pitre on 3/18/16.
//  Copyright © 2016 tee-boy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Extensions)

+ (NSImage *)imageFromText:(NSString *)text size:(CGFloat)size;
+ (NSImage *)imageFromView:(NSView *)view;

@end
