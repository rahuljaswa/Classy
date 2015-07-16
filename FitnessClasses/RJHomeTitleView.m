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
        [_titleView setTintColor:styleManager.themeTextColor];
        _titleView.userInteractionEnabled = YES;
        [self addSubview:_titleView];
        
        CGFloat settingsButtonWidth = 44.0f;
        CGFloat spinnerWidth = 25.0f;
        
        _settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
        _settingsButton.tintColor = styleManager.accentColor;
        _settingsButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, -(settingsButtonWidth/2.0f), 0.0f, 0.0f);
        [_settingsButton setImage:[UIImage tintableImageNamed:@"settingsIcon"] forState:UIControlStateNormal];
        [self addSubview:_settingsButton];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_spinner];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleView, _settingsButton, _spinner);
        NSDictionary *metrics = @{
                                  @"settingsButtonWidth" : @(settingsButtonWidth),
                                  @"spinnerWidth" : @(spinnerWidth)
                                  };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleView]-10-|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_settingsButton]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_spinner]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_settingsButton(settingsButtonWidth)]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_spinner(spinnerWidth)]|" options:0 metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    }
    return self;
}

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
