//
//  RJCreateSelfPacedExerciseInstructionCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateSelfPacedExerciseInstructionCell;

@protocol RJCreateSelfPacedExerciseInstructionCellDelegate <NSObject>

- (void)createSelfPacedExerciseInstructionCellUpButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell;
- (void)createSelfPacedExerciseInstructionCellDownButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell;
- (void)createSelfPacedExerciseInstructionCellTrashButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell;
- (void)createSelfPacedExerciseInstructionCellExerciseButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell;

- (void)createSelfPacedExerciseInstructionCellBeginnerQuantityTextViewDidChange:(RJCreateSelfPacedExerciseInstructionCell *)cell;
- (void)createSelfPacedExerciseInstructionCellIntermediateQuantityTextViewDidChange:(RJCreateSelfPacedExerciseInstructionCell *)cell;
- (void)createSelfPacedExerciseInstructionCellAdvancedQuantityTextViewDidChange:(RJCreateSelfPacedExerciseInstructionCell *)cell;

@end


@class RJParseExerciseInstruction;
@class SZTextView;

@interface RJCreateSelfPacedExerciseInstructionCell : UICollectionViewCell

@property (nonatomic, weak) id<RJCreateSelfPacedExerciseInstructionCellDelegate> delegate;

@property (nonatomic, strong) RJParseExerciseInstruction *exerciseInstruction;

@property (nonatomic, strong, readonly) UIButton *exerciseButton;

@property (nonatomic, strong, readonly) SZTextView *beginnerQuantityTextView;
@property (nonatomic, strong, readonly) SZTextView *intermediateQuantityTextView;
@property (nonatomic, strong, readonly) SZTextView *advancedQuantityTextView;

@property (nonatomic, strong, readonly) UIButton *downButton;
@property (nonatomic, strong, readonly) UIButton *trashButton;
@property (nonatomic, strong, readonly) UIButton *upButton;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@end
