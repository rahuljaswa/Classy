//
//  RJCreateEditChoreographedClassExerciseInstructionCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJArithmeticHelper.h"
#import "RJCreateEditChoreographedClassExerciseInstructionCell.h"
#import "RJParseExerciseInstruction.h"

static CGFloat const kBorderHeight = 0.5f;
static CGFloat const kQuantityTextFieldHeight = 30.0f;


@interface RJCreateEditChoreographedClassExerciseInstructionCell () <UITextFieldDelegate>

@end


@implementation RJCreateEditChoreographedClassExerciseInstructionCell

#pragma mark - Public Properties

- (void)setInstruction:(RJParseExerciseInstruction *)instruction {
    _instruction = instruction;
    self.startPointLabel.text = [NSString hhmmaaForTotalSeconds:[_instruction.startPoint integerValue]];
}

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self.delegate respondsToSelector:@selector(createEditChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:)]) {
        [self.delegate createEditChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:self];
    }
    return NO;
}

#pragma mark - Private Instance Methods

- (void)duplicateButtonPressed:(UIButton *)button {
    [self.delegate createEditChoreographedClassExerciseInstructionCellDidPressDuplicateButton:self];
}

- (void)exerciseButtonPressed:(UIButton *)button {
    [self.delegate createEditChoreographedClassExerciseInstructionCellDidPressExerciseButton:self];
}

- (void)trashButtonPressed:(UIButton *)button {
    [self.delegate createEditChoreographedClassExerciseInstructionCellDidPressTrashButton:self];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _startPointLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _startPointLabel.tintColor = [UIColor clearColor];
        [self.contentView addSubview:_startPointLabel];
        
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
        _startPointLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _quantityTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_buttonsAreaBackground, _startPointLabel, _quantityTextField, _topBorder, _bottomBorder);
        NSDictionary *metrics = @{
                                  @"quantityTextFieldHeight" : @(kQuantityTextFieldHeight),
                                  @"borderHeight" : @(kBorderHeight)
                                  };
        
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBorder(borderHeight)][_buttonsAreaBackground][_startPointLabel][_quantityTextField][_bottomBorder(borderHeight)]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buttonsAreaBackground]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_startPointLabel]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_quantityTextField]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBorder]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_startPointLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.3 constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_buttonsAreaBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0f]];
        
        _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trashButton addTarget:self action:@selector(trashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_trashButton];
        
        _duplicateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_duplicateButton addTarget:self action:@selector(duplicateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_duplicateButton];
        
        _exerciseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exerciseButton addTarget:self action:@selector(exerciseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonsAreaBackground addSubview:_exerciseButton];

        _trashButton.translatesAutoresizingMaskIntoConstraints = NO;
        _exerciseButton.translatesAutoresizingMaskIntoConstraints = NO;
        _duplicateButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *buttonsViews = NSDictionaryOfVariableBindings(_trashButton, _exerciseButton, _duplicateButton);
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_exerciseButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_trashButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_duplicateButton]|" options:0 metrics:nil views:buttonsViews]];
        [_buttonsAreaBackground addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_exerciseButton][_duplicateButton(30)][_trashButton(30)]|" options:0 metrics:nil views:buttonsViews]];
    }
    return self;
}

@end
