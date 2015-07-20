//
//  UIColor+RJAdditions.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/20/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "UIColor+RJAdditions.h"


@implementation UIColor (RJAdditions)

#pragma mark - Private Instance Methods

+ (CGFloat)floatForDistance:(CGFloat)distance betweenPoint:(CGFloat)point andPoint:(CGFloat)otherPoint {
    return (point + (distance*(otherPoint-point)));
}

#pragma mark - Public Instance Methods

+ (UIColor *)colorForDistance:(CGFloat)distance betweenColor:(UIColor *)color andColor:(UIColor *)otherColor {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGFloat otherRed, otherGreen, otherBlue, otherAlpha;
    [otherColor getRed:&otherRed green:&otherGreen blue:&otherBlue alpha:&otherAlpha];
    
    return [UIColor colorWithRed:[self floatForDistance:distance betweenPoint:red andPoint:otherRed]
                           green:[self floatForDistance:distance betweenPoint:green andPoint:otherGreen]
                            blue:[self floatForDistance:distance betweenPoint:blue andPoint:otherBlue]
                           alpha:[self floatForDistance:distance betweenPoint:alpha andPoint:alpha]];
}

@end
