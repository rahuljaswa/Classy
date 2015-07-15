//
//  RJStyleManager.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

@import UIKit;


@interface RJStyleManager : NSObject

@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, strong) UIColor *themeBackgroundColor;
@property (nonatomic, strong) UIColor *themeTextColor;
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *tintBlueColor;
@property (nonatomic, strong) UIColor *tintLightGrayColor;

@property (nonatomic, strong) UIColor *contrastOneLevelColor;
@property (nonatomic, strong) UIColor *contrastTwoLevelsColor;

@property (nonatomic, strong) UIFont *navigationBarFont;

@property (nonatomic, strong) UIFont *giantBoldFont;
@property (nonatomic, strong) UIFont *giantFont;
@property (nonatomic, strong) UIFont *largeBoldFont;
@property (nonatomic, strong) UIFont *largeFont;
@property (nonatomic, strong) UIFont *mediumBoldFont;
@property (nonatomic, strong) UIFont *mediumFont;
@property (nonatomic, strong) UIFont *smallBoldFont;
@property (nonatomic, strong) UIFont *smallFont;
@property (nonatomic, strong) UIFont *verySmallBoldFont;
@property (nonatomic, strong) UIFont *verySmallFont;

+ (NSDictionary *)attributesWithFont:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment;

+ (instancetype)sharedInstance;

- (void)applyGlobalStyles;

@end
