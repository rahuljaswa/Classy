//
//  RJCreateEditChoreographedClassTrackCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateEditChoreographedClassTrackCell;

@protocol RJCreateChoreographedClassTrackCellDelegate <NSObject>

- (void)createEditChoreographedClassTrackCellDownButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell;
- (void)createEditChoreographedClassTrackCellTrackButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell;
- (void)createEditChoreographedClassTrackCellTrashButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell;
- (void)createEditChoreographedClassTrackCellUpButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell;

@end


@class RJParseTrack;

@interface RJCreateEditChoreographedClassTrackCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger startPoint;
@property (nonatomic, strong) RJParseTrack *track;

@property (nonatomic, weak) id<RJCreateChoreographedClassTrackCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIButton *downButton;
@property (nonatomic, strong, readonly) UILabel *timingLabel;
@property (nonatomic, strong, readonly) UIButton *trackButton;
@property (nonatomic, strong, readonly) UIButton *trashButton;
@property (nonatomic, strong, readonly) UIButton *upButton;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *buttonsAreaBackground;
@property (nonatomic, strong, readonly) UIView *topBorder;

@end
