//
//  RJCreateEditSelfPacedExerciseInstructionCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateEditSelfPacedExerciseInstructionCell.h"
#import <SZTextView/SZTextView.h>


@interface RJCreateEditSelfPacedExerciseInstructionCell () <UITextViewDelegate>

@property (nonatomic, assign, getter = hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJCreateEditSelfPacedExerciseInstructionCell

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Private Protocols - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.beginnerQuantityTextView) {
        [self.delegate createEditSelfPacedExerciseInstructionCellBeginnerQuantityTextViewDidChange:self];
    } else if (textView == self.intermediateQuantityTextView) {
        [self.delegate createEditSelfPacedExerciseInstructionCellIntermediateQuantityTextViewDidChange:self];
    } else if (textView == self.advancedQuantityTextView) {
        [self.delegate createEditSelfPacedExerciseInstructionCellAdvancedQuantityTextViewDidChange:self];
    }
}

#pragma mark - Private Instance Methods

- (void)exerciseButtonPressed:(UIButton *)button {
    [self.delegate createEditSelfPacedExerciseInstructionCellExerciseButtonPressed:self];
}

- (void)downButtonPressed:(UIButton *)button {
    [self.delegate createEditSelfPacedExerciseInstructionCellDownButtonPressed:self];
}

- (void)upButtonPressed:(UIButton *)button {
    [self.delegate createEditSelfPacedExerciseInstructionCellUpButtonPressed:self];
}

- (void)trashButtonPressed:(UIButton *)button {
    [self.delegate createEditSelfPacedExerciseInstructionCellTrashButtonPressed:self];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _exerciseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exerciseButton addTarget:self action:@selector(exerciseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_exerciseButton];
        
        _upButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upButton addTarget:self action:@selector(upButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_upButton];
        
        _downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downButton addTarget:self action:@selector(downButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_downButton];
        
        _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trashButton addTarget:self action:@selector(trashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_trashButton];
        
        _beginnerQuantityTextView = [[SZTextView alloc] initWithFrame:CGRectZero];
        _beginnerQuantityTextView.delegate = self;
        [self.contentView addSubview:_beginnerQuantityTextView];
        
        _intermediateQuantityTextView = [[SZTextView alloc] initWithFrame:CGRectZero];
        _intermediateQuantityTextView.delegate = self;
        [self.contentView addSubview:_intermediateQuantityTextView];
        
        _advancedQuantityTextView = [[SZTextView alloc] initWithFrame:CGRectZero];
        _advancedQuantityTextView.delegate = self;
        [self.contentView addSubview:_advancedQuantityTextView];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_topBorder];
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomBorder];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        _beginnerQuantityTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _intermediateQuantityTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _advancedQuantityTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _exerciseButton.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _upButton.translatesAutoresizingMaskIntoConstraints = NO;
        _downButton.translatesAutoresizingMaskIntoConstraints = NO;
        _trashButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_beginnerQuantityTextView, _intermediateQuantityTextView, _advancedQuantityTextView, _exerciseButton, _topBorder, _bottomBorder, _upButton, _downButton, _trashButton);
        
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_exerciseButton]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upButton(30)][_beginnerQuantityTextView][_intermediateQuantityTextView(==_beginnerQuantityTextView)][_advancedQuantityTextView(==_beginnerQuantityTextView)][_trashButton(30)]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_downButton][_beginnerQuantityTextView]" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBorder]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBorder]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_trashButton]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_upButton][_downButton(==_upButton)]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_exerciseButton(40)][_beginnerQuantityTextView]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_exerciseButton][_intermediateQuantityTextView]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_exerciseButton][_advancedQuantityTextView]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBorder(==0.5)]" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomBorder(==0.5)]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_intermediateQuantityTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_beginnerQuantityTextView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:_advancedQuantityTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_beginnerQuantityTextView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
