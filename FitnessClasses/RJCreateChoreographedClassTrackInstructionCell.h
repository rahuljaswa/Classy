//
//  RJCreateChoreographedClassTrackInstructionCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateChoreographedClassTrackInstructionCell;

@protocol RJCreateChoreographedClassTrackInstructionCellDelegate <NSObject>

- (void)createChoreographedClassTrackInstructionCellTrackButtonPressed:(RJCreateChoreographedClassTrackInstructionCell *)cell;
- (void)createChoreographedClassTrackInstructionCellStartPointDidChange:(RJCreateChoreographedClassTrackInstructionCell *)cell;

@end


@class RJParseTrackInstruction;

@interface RJCreateChoreographedClassTrackInstructionCell : UICollectionViewCell

@property (nonatomic, strong) RJParseTrackInstruction *instruction;

@property (nonatomic, weak) id<RJCreateChoreographedClassTrackInstructionCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIButton *trackButton;
@property (nonatomic, strong, readonly) UITextField *startPointTextField;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@property (nonatomic, assign, readonly) NSInteger startPoint;

@end
