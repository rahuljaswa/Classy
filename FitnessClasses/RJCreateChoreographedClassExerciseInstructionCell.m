//
//  RJCreateChoreographedClassExerciseInstructionCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJArithmeticHelper.h"
#import "RJCreateChoreographedClassExerciseInstructionCell.h"
#import "RJParseExerciseInstruction.h"

static CGFloat const kBorderHeight = 0.5f;
static CGFloat const kQuantityTextFieldHeight = 30.0f;


@interface RJCreateChoreographedClassExerciseInstructionCell () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong, readwrite) UITextField *startPointTextField;

@property (nonatomic, assign) NSInteger numberOfHours;
@property (nonatomic, assign) NSInteger numberOfMinutes;
@property (nonatomic, assign) NSInteger numberOfSeconds;

@end


@implementation RJCreateChoreographedClassExerciseInstructionCell

#pragma mark - Public Properties

- (void)setInstruction:(RJParseExerciseInstruction *)instruction {
    _instruction = instruction;
    
    NSInteger hours, minutes, seconds;
    [RJArithmeticHelper extractHours:&hours minutes:&minutes seconds:&seconds forLength:[instruction.startPoint integerValue]];

    self.numberOfHours = hours;
    self.numberOfMinutes = minutes;
    self.numberOfSeconds = seconds;
    self.startPointTextField.text = [NSString hhmmaaForTotalSeconds:self.startPoint];
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
    if ([self.delegate respondsToSelector:@selector(createChoreographedClassExerciseInstructionCellStartPointDidChange:)]) {
        [self.delegate createChoreographedClassExerciseInstructionCellStartPointDidChange:self];
    }
}

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self.delegate respondsToSelector:@selector(createChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:)]) {
        [self.delegate createChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:self];
    }
    return NO;
}

#pragma mark - Private Instance Methods

- (void)exerciseButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(createChoreographedClassExerciseInstructionCellDidPressExerciseButton:)]) {
        [self.delegate createChoreographedClassExerciseInstructionCellDidPressExerciseButton:self];
    }
}

- (void)trashButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(createChoreographedClassExerciseInstructionCellDidPressTrashButton:)]) {
        [self.delegate createChoreographedClassExerciseInstructionCellDidPressTrashButton:self];
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
        
        _startPointTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _startPointTextField.tintColor = [UIColor clearColor];
        UIPickerView *startPointPicker = [[UIPickerView alloc] init];
        startPointPicker.delegate = self;
        startPointPicker.dataSource = self;
        _startPointTextField.inputView = startPointPicker;
        [self.contentView addSubview:_startPointTextField];
        
        _quantityTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _quantityTextField.delegate = self;
        [self.contentView addSubview:_quantityTextField];
        
        _buttonsAreaBackground = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_buttonsAreaBackground];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_topBorder];
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomBorder];
        
        _buttonsAreaBackground.translatesAutoresizingMaskIntoConstraints = NO;
        _startPointTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _quantityTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_buttonsAreaBackground, _startPointTextField, _quantityTextField, _topBorder, _bottomBorder);
        NSDictionary *metrics = @{
                                  @"quantityTextFieldHeight" : @(kQuantityTextFieldHeight),
                                  @"borderHeight" : @(kBorderHeight)
                                  };
        
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBorder(borderHeight)][_buttonsAreaBackground][_startPointTextField][_quantityTextField][_bottomBorder(borderHeight)]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buttonsAreaBackground]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_startPointTextField]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_quantityTextField]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_startPointTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.3 constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_buttonsAreaBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0f]];
        
        _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trashButton addTarget:self action:@selector(trashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_trashButton];
        
        _exerciseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exerciseButton addTarget:self action:@selector(exerciseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_exerciseButton];

        _trashButton.translatesAutoresizingMaskIntoConstraints = NO;
        _exerciseButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *buttonsViews = NSDictionaryOfVariableBindings(_trashButton, _exerciseButton);
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_exerciseButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_trashButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_exerciseButton]" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_trashButton]|" options:0 metrics:nil views:buttonsViews]];
    }
    return self;
}

@end
