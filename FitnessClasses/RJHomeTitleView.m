//
//  RJHomeTitleView.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJHomeTitleView.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"


@implementation RJHomeTitleView

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        
        _titleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _titleView.translatesAutoresizingMaskIntoConstraints = NO;
        _titleView.image = [UIImage tintableImageNamed:@"wordmark"];
        _titleView.contentMode = UIViewContentModeScaleAspectFit;
        [_titleView setTintColor:styleManager.windowTintColor];
        _titleView.userInteractionEnabled = YES;
        [self addSubview:_titleView];
        
        _settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
        _settingsButton.tintColor = styleManager.accentColor;
        _settingsButton.contentMode = UIViewContentModeLeft;
        [_settingsButton setImage:[UIImage tintableImageNamed:@"settingsIcon"] forState:UIControlStateNormal];
        [self addSubview:_settingsButton];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleView, _settingsButton);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleView]-10-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_settingsButton]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_settingsButton]" options:0 metrics:nil views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    }
    return self;
}

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
