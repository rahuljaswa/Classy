//
//  UIBarButtonItem+RJAdditions.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIBarButtonItem (RJAdditions)

+ (instancetype)cancelBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor;
+ (instancetype)minimizeBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor;
+ (instancetype)playBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor;
+ (instancetype)toggleBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor;

@end
