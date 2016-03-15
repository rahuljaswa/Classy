//
//  RJTutorialCollectionViewCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/15/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJTutorialCollectionViewCell.h"
#import <UIToolkitIOS/RJInsetLabel.h>


@interface RJTutorialCollectionViewCell ()

@property (nonatomic, assign, getter=hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJTutorialCollectionViewCell

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _detailTextLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _detailTextLabel.numberOfLines = 0;
        _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_detailTextLabel];
        
        _textLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_textLabel];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_imageView];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat textLabelWidth = (CGRectGetWidth(self.bounds) - self.textLabel.insets.left - self.textLabel.insets.right);
    if (self.textLabel.preferredMaxLayoutWidth != textLabelWidth) {
        self.textLabel.preferredMaxLayoutWidth = textLabelWidth;
    }
    
    CGFloat detailTextLabelWidth = (CGRectGetWidth(self.bounds) - self.detailTextLabel.insets.left - self.detailTextLabel.insets.right);
    if (self.detailTextLabel.preferredMaxLayoutWidth != detailTextLabelWidth) {
        self.detailTextLabel.preferredMaxLayoutWidth = detailTextLabelWidth;
    }
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        UIView *detailTextLabel = self.detailTextLabel;
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *textLabel = self.textLabel;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *imageView = self.imageView;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *button = self.button;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(detailTextLabel, textLabel, imageView, button);
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[button]" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[textLabel][detailTextLabel]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[detailTextLabel]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textLabel]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:-20.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
