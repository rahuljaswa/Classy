//
//  UIImage+RJAdditions.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (RJAdditions)

+ (instancetype)imageWithColor:(UIColor *)color;
+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (instancetype)tintableImageNamed:(NSString *)named;

@end
