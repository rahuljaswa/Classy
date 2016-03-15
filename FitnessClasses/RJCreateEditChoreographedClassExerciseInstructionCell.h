//
//  RJCreateEditChoreographedClassExerciseInstructionCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateEditChoreographedClassExerciseInstructionCell;

@protocol RJCreateEditChoreographedClassExerciseInstructionCellDelegate <NSObject>

- (void)createEditChoreographedClassExerciseInstructionCellDidPressDuplicateButton:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell;
- (void)createEditChoreographedClassExerciseInstructionCellDidPressExerciseButton:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell;
- (void)createEditChoreographedClassExerciseInstructionCellDidPressTrashButton:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell;
- (void)createEditChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell;

@end


@class RJParseExerciseInstruction;

@interface RJCreateEditChoreographedClassExerciseInstructionCell : UICollectionViewCell

@property (nonatomic, strong) RJParseExerciseInstruction *instruction;

@property (nonatomic, weak) id<RJCreateEditChoreographedClassExerciseInstructionCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIButton *duplicateButton;
@property (nonatomic, strong, readonly) UIButton *exerciseButton;
@property (nonatomic, strong, readonly) UITextField *quantityTextField;
@property (nonatomic, strong, readonly) UILabel *startPointLabel;
@property (nonatomic, strong, readonly) UIButton *trashButton;

@property (nonatomic, strong, readonly) UIView *buttonsAreaBackground;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@end
