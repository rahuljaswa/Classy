//
//  RJCreateChoreographedClassExerciseInstructionCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateChoreographedClassExerciseInstructionCell;

@protocol RJCreateChoreographedClassExerciseInstructionCellDelegate <NSObject>

- (void)createChoreographedClassExerciseInstructionCellDidPressExerciseButton:(RJCreateChoreographedClassExerciseInstructionCell *)cell;
- (void)createChoreographedClassExerciseInstructionCellDidPressTrashButton:(RJCreateChoreographedClassExerciseInstructionCell *)cell;
- (void)createChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:(RJCreateChoreographedClassExerciseInstructionCell *)cell;
- (void)createChoreographedClassExerciseInstructionCellStartPointDidChange:(RJCreateChoreographedClassExerciseInstructionCell *)cell;

@end


@class RJParseExerciseInstruction;

@interface RJCreateChoreographedClassExerciseInstructionCell : UICollectionViewCell

@property (nonatomic, strong) RJParseExerciseInstruction *instruction;

@property (nonatomic, weak) id<RJCreateChoreographedClassExerciseInstructionCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIButton *exerciseButton;
@property (nonatomic, strong, readonly) UITextField *quantityTextField;
@property (nonatomic, strong, readonly) UITextField *startPointTextField;
@property (nonatomic, strong, readonly) UIButton *trashButton;

@property (nonatomic, strong, readonly) UIView *buttonsAreaBackground;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@property (nonatomic, assign, readonly) NSInteger startPoint;

@end
