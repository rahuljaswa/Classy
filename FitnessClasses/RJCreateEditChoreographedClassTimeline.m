//
//  RJCreateEditChoreographedClassTimeline.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/29/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJCreateEditChoreographedClassCollectionViewLayout.h"
#import "RJCreateEditChoreographedClassTimeline.h"
#import "RJStyleManager.h"


@implementation RJCreateEditChoreographedClassTimeline

#pragma mark - Public Properties

- (void)setFont:(UIFont *)font {
    if (![_font isEqual:font]) {
        _font = font;
        [self setNeedsDisplay];
    }
}

- (void)setLabelBackgroundColor:(UIColor *)labelBackgroundColor {
    if (![_labelBackgroundColor isEqual:labelBackgroundColor]) {
        _labelBackgroundColor = labelBackgroundColor;
        [self setNeedsDisplay];
    }
}

- (void)setLabelInsets:(UIEdgeInsets)labelInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_labelInsets, labelInsets)) {
        _labelInsets = labelInsets;
        [self setNeedsDisplay];
    }
}

#pragma mark - Public Instance Methods

- (void)drawRect:(CGRect)rect {
    NSInteger totalDuration = [RJCreateEditChoreographedClassCollectionViewLayout durationForLength:CGRectGetHeight(rect)];
    NSInteger tickIncrementLength = 15;
    NSInteger firstStringIncrement = 30;
    NSInteger stringIncrementLength = 60;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextBeginPath(context);
    
    CGFloat lineX = CGRectGetWidth(rect)/2.0f;
    CGContextMoveToPoint(context, lineX, CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, lineX, CGRectGetMaxY(rect));
    CGContextStrokePath(context);
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : self.font,
                                 NSForegroundColorAttributeName : self.labelColor
                                 };
    CGFloat tickWidth = kCreateEditChoreographedClassCollectionViewLayoutTickLength;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(-self.labelInsets.top, -self.labelInsets.left, -self.labelInsets.bottom, -self.labelInsets.right);
    
    NSInteger durationCounter = 0;
    NSInteger stringCounter = firstStringIncrement;
    while (durationCounter <= totalDuration) {
        CGFloat yForCounter = [RJCreateEditChoreographedClassCollectionViewLayout lengthForDuration:durationCounter];
        
        if (durationCounter == stringCounter) {
            NSString *string = [NSString hhmmaaForTotalSeconds:durationCounter];
            CGRect stringRect = [string boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
            stringRect.origin.x = CGRectGetWidth(rect)/2.0f - CGRectGetWidth(stringRect)/2.0f;
            stringRect.origin.y = (yForCounter - CGRectGetHeight(stringRect)/2.0f);
            
            CGRect stringBackgroundRect = UIEdgeInsetsInsetRect(stringRect, insets);
            CGContextSetFillColorWithColor(context, self.labelBackgroundColor.CGColor);
            CGContextFillEllipseInRect(context, stringBackgroundRect);
            
            [string drawInRect:stringRect withAttributes:attributes];
            
            stringCounter += stringIncrementLength;
        } else {
            CGContextBeginPath(context);
            CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
            CGFloat tickStartingPoint = (CGRectGetWidth(rect)/2.0f - tickWidth/2.0f);
            CGContextMoveToPoint(context, tickStartingPoint, yForCounter);
            CGContextAddLineToPoint(context, tickStartingPoint + tickWidth, yForCounter);
            CGContextStrokePath(context);
        }
        
        durationCounter += tickIncrementLength;
    }
    
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
}

#pragma mark - Public Class Methods

+ (NSString *)kind {
    return @"RJCreateEditChoreographedClassTimeline";
}

@end
