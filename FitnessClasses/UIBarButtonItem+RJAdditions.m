//
//  UIBarButtonItem+RJAdditions.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "UIBarButtonItem+RJAdditions.h"
#import <UIToolkitIOS/UIImage+RJAdditions.h>


@implementation UIBarButtonItem (RJAdditions)

+ (instancetype)cancelBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(8.0f, -30.0f, 8.0f, 0.0f);
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancelButton addTarget:target action:action forControlEvents:controlEvents];
    [cancelButton setImage:[UIImage tintableImageNamed:@"cancelIcon"] forState:UIControlStateNormal];
    [cancelButton setTintColor:tintColor];
    return [[self alloc] initWithCustomView:cancelButton];
}

+ (instancetype)minimizeBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(8.0f, -30.0f, 8.0f, 0.0f);
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancelButton addTarget:target action:action forControlEvents:controlEvents];
    [cancelButton setImage:[UIImage tintableImageNamed:@"minimizeIcon"] forState:UIControlStateNormal];
    [cancelButton setTintColor:tintColor];
    return [[self alloc] initWithCustomView:cancelButton];
}

+ (instancetype)playBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(8.0f, 0.0f, 8.0f, -30.0f);
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancelButton addTarget:target action:action forControlEvents:controlEvents];
    [cancelButton setImage:[UIImage tintableImageNamed:@"circledPlayIcon"] forState:UIControlStateNormal];
    [cancelButton setTintColor:tintColor];
    return [[self alloc] initWithCustomView:cancelButton];
}

+ (instancetype)toggleBarButtonItemWithTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents tintColor:(UIColor *)tintColor {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(8.0f, 0.0f, 8.0f, -30.0f);
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancelButton addTarget:target action:action forControlEvents:controlEvents];
    [cancelButton setImage:[UIImage tintableImageNamed:@"toggleIcon"] forState:UIControlStateNormal];
    [cancelButton setTintColor:tintColor];
    return [[self alloc] initWithCustomView:cancelButton];
}

@end
