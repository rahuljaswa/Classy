//
//  RJCreateEditSelfPacedExerciseInstructionCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateEditSelfPacedExerciseInstructionCell;

@protocol RJCreateEditSelfPacedExerciseInstructionCellDelegate <NSObject>

- (void)createEditSelfPacedExerciseInstructionCellUpButtonPressed:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;
- (void)createEditSelfPacedExerciseInstructionCellDownButtonPressed:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;
- (void)createEditSelfPacedExerciseInstructionCellDuplicateButtonPressed:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;
- (void)createEditSelfPacedExerciseInstructionCellTrashButtonPressed:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;
- (void)createEditSelfPacedExerciseInstructionCellExerciseButtonPressed:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;

- (void)createEditSelfPacedExerciseInstructionCellAllLevelsQuantityTextViewDidChange:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;
- (void)createEditSelfPacedExerciseInstructionCellBeginnerQuantityTextViewDidChange:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;
- (void)createEditSelfPacedExerciseInstructionCellIntermediateQuantityTextViewDidChange:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;
- (void)createEditSelfPacedExerciseInstructionCellAdvancedQuantityTextViewDidChange:(RJCreateEditSelfPacedExerciseInstructionCell *)cell;

@end


@class RJParseExerciseInstruction;
@class SZTextView;

@interface RJCreateEditSelfPacedExerciseInstructionCell : UICollectionViewCell

@property (nonatomic, weak) id<RJCreateEditSelfPacedExerciseInstructionCellDelegate> delegate;

@property (nonatomic, strong) RJParseExerciseInstruction *exerciseInstruction;

@property (nonatomic, strong, readonly) UIButton *exerciseButton;

@property (nonatomic, strong, readonly) SZTextView *allLevelsQuantityTextView;
@property (nonatomic, strong, readonly) SZTextView *beginnerQuantityTextView;
@property (nonatomic, strong, readonly) SZTextView *intermediateQuantityTextView;
@property (nonatomic, strong, readonly) SZTextView *advancedQuantityTextView;

@property (nonatomic, strong, readonly) UIButton *downButton;
@property (nonatomic, strong, readonly) UIButton *duplicateButton;
@property (nonatomic, strong, readonly) UIButton *trashButton;
@property (nonatomic, strong, readonly) UIButton *upButton;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@end
