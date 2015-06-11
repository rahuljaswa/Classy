//
//  RJStackedTitleView.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJStackedTitleView.h"


@implementation RJStackedTitleView

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_detailTextLabel];
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_textLabel];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_detailTextLabel, _textLabel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel][_detailTextLabel]-5-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textLabel]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_detailTextLabel]|" options:0 metrics:nil views:views]];
    }
    return self;
}

@end
