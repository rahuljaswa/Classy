//
//  RJExerciseStepCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJExerciseStepCell.h"
#import <UIToolkitIOS/RJInsetLabel.h>


@interface RJExerciseStepCell ()

@property (nonatomic, assign, getter=hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJExerciseStepCell

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _image = [[UIImageView alloc] initWithFrame:CGRectZero];
        _textLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.numberOfLines = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = (CGRectGetWidth(self.bounds) - self.textLabel.insets.left - self.textLabel.insets.right);
    if (self.textLabel.preferredMaxLayoutWidth != width) {
        self.textLabel.preferredMaxLayoutWidth = width;
    }
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        UIView *image = self.image;
        image.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:image];
        
        UIView *textLabel = self.textLabel;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:textLabel];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(image, textLabel);
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[image]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[textLabel]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[image]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textLabel]|" options:0 metrics:nil views:views]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
