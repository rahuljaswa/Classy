//
//  RJGalleryCellAccessoriesView.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryCellAccessoriesView.h"
#import "RJStyleManager.h"


@interface RJGalleryCellAccessoriesView ()

@property (nonatomic, assign, getter=hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJGalleryCellAccessoriesView

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playsCount = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_playsCount];
        
        _playsIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_playsIcon];
        
        _summary = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_summary];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        UIView *playsCount = self.playsCount;
        playsCount.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *playsIcon = self.playsIcon;
        playsIcon.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *summary = self.summary;
        summary.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(playsCount, playsIcon, summary);
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[playsCount][playsIcon(==16)]" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[summary]-5-|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[summary]-5-|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[playsIcon]-5-|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[playsCount]-5-|" options:0 metrics:nil views:views]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
