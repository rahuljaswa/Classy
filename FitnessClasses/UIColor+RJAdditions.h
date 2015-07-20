//
//  UIColor+RJAdditions.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/20/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (RJAdditions)

+ (UIColor *)colorForDistance:(CGFloat)distance betweenColor:(UIColor *)color andColor:(UIColor *)otherColor;

@end
