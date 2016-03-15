//
//  RJCreateEditChoreographedClassTrackCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJArithmeticHelper.h"
#import "RJCreateEditChoreographedClassTrackCell.h"
#import "RJParseTrack.h"

static CGFloat const kBorderHeight = 0.5f;
static CGFloat const kTrackButtonHeight = 30.0f;
static CGFloat const ktimingLabelHeight = 30.0f;


@interface RJCreateEditChoreographedClassTrackCell ()

@property (nonatomic, strong, readwrite) UILabel *timingLabel;

@property (nonatomic, assign) NSInteger numberOfHours;
@property (nonatomic, assign) NSInteger numberOfMinutes;
@property (nonatomic, assign) NSInteger numberOfSeconds;

@end


@implementation RJCreateEditChoreographedClassTrackCell

#pragma mark - Public Properties

- (void)setTrack:(RJParseTrack *)track {
    _track = track;
    [self updateTimingLabelText];
}

- (void)setStartPoint:(NSInteger)startPoint {
    _startPoint = startPoint;
    [self updateTimingLabelText];
}

#pragma mark - Private Instance Methods

- (void)trackButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(createEditChoreographedClassTrackCellTrackButtonPressed:)]) {
        [self.delegate createEditChoreographedClassTrackCellTrackButtonPressed:self];
    }
}

- (void)upButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(createEditChoreographedClassTrackCellUpButtonPressed:)]) {
        [self.delegate createEditChoreographedClassTrackCellUpButtonPressed:self];
    }
}

- (void)downButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(createEditChoreographedClassTrackCellDownButtonPressed:)]) {
        [self.delegate createEditChoreographedClassTrackCellDownButtonPressed:self];
    }
}

- (void)trashButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(createEditChoreographedClassTrackCellTrashButtonPressed:)]) {
        [self.delegate createEditChoreographedClassTrackCellTrashButtonPressed:self];
    }
}

- (void)updateTimingLabelText {
    NSInteger hours, minutes, seconds;
    [RJArithmeticHelper extractHours:&hours minutes:&minutes seconds:&seconds forLength:self.startPoint];
    
    self.numberOfHours = hours;
    self.numberOfMinutes = minutes;
    self.numberOfSeconds = seconds;
    
    NSString *startPoint = [NSString hhmmaaForTotalSeconds:self.startPoint];
    NSString *endPoint = [NSString hhmmaaForTotalSeconds:(self.startPoint + [self.track.length integerValue])];
    
    self.timingLabel.text = [NSString stringWithFormat:@"%@ - %@", startPoint, endPoint];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _numberOfHours = 0;
        _numberOfMinutes = 0;
        _numberOfSeconds = 0;
        
        _trackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trackButton addTarget:self action:@selector(trackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_trackButton];
        
        _timingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timingLabel.tintColor = [UIColor clearColor];
        [self.contentView addSubview:_timingLabel];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_topBorder];
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomBorder];
        
        _buttonsAreaBackground = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_buttonsAreaBackground];
        
        _buttonsAreaBackground.translatesAutoresizingMaskIntoConstraints = NO;
        _trackButton.translatesAutoresizingMaskIntoConstraints = NO;
        _timingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_trackButton, _timingLabel, _topBorder, _bottomBorder, _buttonsAreaBackground);
        NSDictionary *metrics = @{
                                  @"timingLabelHeight" : @(ktimingLabelHeight),
                                  @"trackButtonHeight" : @(kTrackButtonHeight),
                                  @"borderHeight" : @(kBorderHeight)
                                  };
        
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBorder(borderHeight)][_buttonsAreaBackground][_timingLabel][_trackButton][_bottomBorder(borderHeight)]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buttonsAreaBackground]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_trackButton]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_timingLabel]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_timingLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.2 constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_buttonsAreaBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0f]];
        
        _downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downButton addTarget:self action:@selector(downButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_downButton];
        
        _upButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upButton addTarget:self action:@selector(upButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_upButton];
        
        _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trashButton addTarget:self action:@selector(trashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_trashButton];
        
        _downButton.translatesAutoresizingMaskIntoConstraints = NO;
        _upButton.translatesAutoresizingMaskIntoConstraints = NO;
        _trashButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *buttonsViews = NSDictionaryOfVariableBindings(_downButton, _upButton, _trashButton);
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_upButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_downButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_trashButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upButton][_downButton]" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_trashButton]|" options:0 metrics:nil views:buttonsViews]];
    }
    return self;
}

@end
