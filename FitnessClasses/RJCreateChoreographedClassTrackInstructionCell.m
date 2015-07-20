//
//  RJCreateChoreographedClassTrackInstructionCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJArithmeticHelper.h"
#import "RJCreateChoreographedClassTrackInstructionCell.h"
#import "RJParseTrack.h"
#import "RJParseTrackInstruction.h"

static CGFloat const kBorderHeight = 0.5f;
static CGFloat const kTrackButtonHeight = 30.0f;
static CGFloat const kStartPointTextFieldHeight = 30.0f;


@interface RJCreateChoreographedClassTrackInstructionCell () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong, readwrite) UITextField *startPointTextField;

@property (nonatomic, assign) NSInteger numberOfHours;
@property (nonatomic, assign) NSInteger numberOfMinutes;
@property (nonatomic, assign) NSInteger numberOfSeconds;

@end


@implementation RJCreateChoreographedClassTrackInstructionCell

#pragma mark - Public Properties

- (void)setInstruction:(RJParseTrackInstruction *)instruction {
    _instruction = instruction;
    
    NSInteger hours, minutes, seconds;
    [RJArithmeticHelper extractHours:&hours minutes:&minutes seconds:&seconds forLength:[instruction.startPoint integerValue]];
    
    self.numberOfHours = hours;
    self.numberOfMinutes = minutes;
    self.numberOfSeconds = seconds;
    
    NSString *startPoint = [NSString hhmmaaForTotalSeconds:self.startPoint];
    NSString *endPoint = [NSString hhmmaaForTotalSeconds:(self.startPoint + [instruction.track.length integerValue])];
    
    self.startPointTextField.text = [NSString stringWithFormat:@"%@ - %@", startPoint, endPoint];
}

- (NSInteger)startPoint {
    return (self.numberOfHours*3600 + self.numberOfMinutes*60 + self.numberOfSeconds);
}

#pragma mark - Private Protocols - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 3;
    } else {
        return 60;
    }
}

#pragma mark - Private Protocols - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = nil;
    if (component == 0) {
        NSString *rowNumber = [NSString stringWithFormat:@"%lu", (unsigned long)row];
        if (row == 0) {
            title = [NSString stringWithFormat:@"%@ Hrs", rowNumber];
        } else {
            title = rowNumber;
        }
    } else if (component == 1) {
        NSString *rowNumber = [NSString stringWithFormat:@"%lu", (unsigned long)row];
        if (row == 0) {
            title = [NSString stringWithFormat:@"%@ Mins", rowNumber];
        } else {
            title = rowNumber;
        }
    } else {
        NSString *rowNumber = [NSString stringWithFormat:@"%lu", (unsigned long)row];
        if (row == 0) {
            title = [NSString stringWithFormat:@"%@ Secs", rowNumber];
        } else {
            title = rowNumber;
        }
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.numberOfHours = row;
    } else if (component == 1) {
        self.numberOfMinutes = row;
    } else {
        self.numberOfSeconds = row;
    }
    self.startPointTextField.text = [NSString hhmmaaForTotalSeconds:self.startPoint];
    if ([self.delegate respondsToSelector:@selector(createChoreographedClassTrackInstructionCellStartPointDidChange:)]) {
        [self.delegate createChoreographedClassTrackInstructionCellStartPointDidChange:self];
    }
}

#pragma mark - Private Instance Methods

- (void)trackButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(createChoreographedClassTrackInstructionCellTrackButtonPressed:)]) {
        [self.delegate createChoreographedClassTrackInstructionCellTrackButtonPressed:self];
    }
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
        
        _startPointTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _startPointTextField.tintColor = [UIColor clearColor];
        UIPickerView *startPointPicker = [[UIPickerView alloc] init];
        startPointPicker.delegate = self;
        startPointPicker.dataSource = self;
        _startPointTextField.inputView = startPointPicker;
        [self.contentView addSubview:_startPointTextField];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_topBorder];
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomBorder];
        
        _trackButton.translatesAutoresizingMaskIntoConstraints = NO;
        _startPointTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_trackButton, _startPointTextField, _topBorder, _bottomBorder);
        NSDictionary *metrics = @{
                                  @"startPointTextFieldHeight" : @(kStartPointTextFieldHeight),
                                  @"trackButtonHeight" : @(kTrackButtonHeight),
                                  @"borderHeight" : @(kBorderHeight)
                                  };
        
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBorder(borderHeight)][_startPointTextField][_trackButton][_bottomBorder(borderHeight)]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_trackButton]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_startPointTextField]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_startPointTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0.0f]];
    }
    return self;
}

@end
