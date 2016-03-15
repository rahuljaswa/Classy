//
//  RJGalleryCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryCell.h"
#import "RJGalleryCell_FastImageCache.h"
#import "RJStyleManager.h"
#import <UIToolkitIOS/RJInsetLabel.h>


@interface RJGalleryCell ()

@property (nonatomic, strong) NSArray *dynamicConstraints;
@property (nonatomic, strong, readonly) UIView *maskView;
@property (nonatomic, assign, getter=hasSetupConstraints) BOOL setupConstraints;

@end


@implementation RJGalleryCell

#pragma mark - Public Properties

- (void)setAccessoriesView:(UIView *)accessoriesView {
    if (_accessoriesView != accessoriesView) {
        _accessoriesView = accessoriesView;
        
        UIView *accessoriesView = _accessoriesView;
        accessoriesView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:accessoriesView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(accessoriesView);
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[accessoriesView]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[accessoriesView(30)]|" options:0 metrics:nil views:views]];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    if (_selectedColor != selectedColor) {
        _selectedColor = selectedColor;
        self.selectedBackgroundView.backgroundColor = [_selectedColor colorWithAlphaComponent:0.8f];
    }
}

- (void)setMask:(BOOL)mask {
    _mask = mask;
    if (_mask) {
        if (_maskView) {
            [self.contentView insertSubview:_maskView belowSubview:self.title];
        } else {
            _maskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
            _maskView.backgroundColor = [RJStyleManager sharedInstance].maskColor;
            [self.contentView insertSubview:_maskView belowSubview:self.title];
        }
    } else {
        [_maskView removeFromSuperview];
    }
    [self updateConstraints];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.shouldHaveSelectedTitle) {
        if (selected) {
            self.title.textColor = self.selectedTitleColor;
            self.title.backgroundColor = self.selectedTitleBackgroundColor;
        } else {
            self.title.textColor = self.unselectedTitleColor;
            self.title.backgroundColor = self.unselectedTitleBackgroundColor;
        }
    }
}

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Private Instance Methods - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
        self.selectedBackgroundView = [[UIView alloc] init];
        
        self.clipsToBounds = YES;
        
        _setupConstraints = NO;
        
        _title = [[RJInsetLabel alloc] initWithFrame:frame];
        _title.numberOfLines = 3;
        _title.lineBreakMode = NSLineBreakByTruncatingTail;
        _title.textColor = [UIColor whiteColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.layer.cornerRadius = 3.0f;
        _title.clipsToBounds = YES;
        [self.contentView addSubview:_title];
        
        _image = [[UIImageView alloc] initWithFrame:frame];
        [self.backgroundView addSubview:_image];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.backgroundView addSubview:_spinner];
    }
    return self;
}

#pragma mark - Private Instance Methods - Layout

- (void)updateConstraints {
    if (!self.hasSetupConstraints) {
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *i = self.image;
        i.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *s = self.spinner;
        s.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *backgroundViews = NSDictionaryOfVariableBindings(i, s);
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[i]|"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[i]|"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-<=10-[s]"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        [self.backgroundView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-<=10-[s]"
                                                 options:0
                                                 metrics:nil
                                                   views:backgroundViews]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.title
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.title
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f
                                       constant:0.0f]];
        self.title.preferredMaxLayoutWidth = (CGRectGetWidth(self.contentView.bounds) - 2.0f*10.0f);
        
        self.setupConstraints = YES;
    }
    
    if (self.dynamicConstraints) {
        [self.backgroundView removeConstraints:self.dynamicConstraints];
    }
    
    if (self.mask) {
        self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.title
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f
                                       constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.title
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1.0f
                                       constant:10.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.maskView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.title
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f
                                       constant:10.0f]];
    }
    
    [super updateConstraints];
}

@end
