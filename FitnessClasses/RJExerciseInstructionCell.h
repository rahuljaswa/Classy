//
//  RJExerciseInstructionCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJExerciseInstructionCell;

@protocol RJExerciseInstructionCellDelegate <NSObject>

- (void)exerciseInstructionCellDidSelectLeftSideAccessoryButton:(RJExerciseInstructionCell *)exerciseInstructionCell;

@end


@class RJParseExerciseInstruction;
@class RJInsetLabel;

@interface RJExerciseInstructionCell : UICollectionViewCell

@property (nonatomic, weak) id<RJExerciseInstructionCellDelegate> delegate;

@property (nonatomic, strong) RJParseExerciseInstruction *exerciseInstruction;
@property (nonatomic, assign) BOOL minimized;


@property (nonatomic, strong, readonly) UIImageView *accessoryImageView;
@property (nonatomic, strong, readonly) UIButton *leftSideAccessoryButton;
@property (nonatomic, strong, readonly) RJInsetLabel *quantityLabelAdvanced;
@property (nonatomic, strong, readonly) RJInsetLabel *quantityLabelAllLevels;
@property (nonatomic, strong, readonly) RJInsetLabel *quantityLabelBeginner;
@property (nonatomic, strong, readonly) RJInsetLabel *quantityLabelIntermediate;
@property (nonatomic, strong, readonly) UIView *spacer;
@property (nonatomic, strong, readonly) RJInsetLabel *titleLabel;

@end
