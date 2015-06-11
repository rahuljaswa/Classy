//
//  UIImage+RJAdditions.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "UIImage+RJAdditions.h"


@implementation UIImage (RJAdditions)

+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (instancetype)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (instancetype)tintableImageNamed:(NSString *)named {
    return [[UIImage imageNamed:named] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
