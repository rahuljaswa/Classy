//
//  RJStyleManager.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJStyleManager.h"
#import "RJTransparentNavigationBarController.h"
#import "UIImage+RJAdditions.h"


@implementation RJStyleManager

#pragma mark - Public Instance Methods

- (void)applyGlobalStyles {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:self.themeBackgroundColor] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:self.themeTextColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{
       NSFontAttributeName : self.navigationBarFont,
       NSForegroundColorAttributeName : self.titleColor
       }
     ];
    
    UINavigationBar *transparentNavigationBar = [UINavigationBar appearanceWhenContainedIn:[RJTransparentNavigationBarController class], nil];
    [transparentNavigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [transparentNavigationBar setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    [transparentNavigationBar setTranslucent:YES];
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage tintableImageNamed:@"backwardIconSmall"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage tintableImageNamed:@"backwardIconSmall"]];
    
    [[UIBarButtonItem appearance] setTintColor:self.accentColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - Public Class Methods

+ (NSDictionary *)attributesWithFont:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = textAlignment;
    return @{
             NSFontAttributeName : font,
             NSForegroundColorAttributeName : textColor,
             NSParagraphStyleAttributeName : style
             };
}

+ (instancetype)sharedInstance {
    static RJStyleManager *_styleManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _styleManager = [[RJStyleManager alloc] init];
    });
    return _styleManager;
}

@end
