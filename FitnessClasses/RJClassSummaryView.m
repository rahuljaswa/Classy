//
//  RJClassSummaryView.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJClassSummaryView.h"


@implementation RJClassSummaryView

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _classTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _track = [[UILabel alloc] initWithFrame:CGRectZero];
        _trackArtwork = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        UIView *classTitle = _classTitle;
        classTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:classTitle];
        UIView *playPauseButton = _playPauseButton;
        playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:playPauseButton];
        UIView *track = _track;
        track.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:track];
        UIView *trackArtwork = _trackArtwork;
        trackArtwork.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:trackArtwork];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(classTitle, playPauseButton, track, trackArtwork);
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[trackArtwork]|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playPauseButton]|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[classTitle][track]-6-|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[trackArtwork]-5-[classTitle]-5-[playPauseButton]|" options:0 metrics:nil views:views]];
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[trackArtwork]-5-[track]-5-[playPauseButton]|" options:0 metrics:nil views:views]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:trackArtwork attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:playPauseButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:playPauseButton attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    }
    return self;
}

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
