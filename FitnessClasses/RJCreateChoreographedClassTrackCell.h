//
//  RJCreateChoreographedClassTrackCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateChoreographedClassTrackCell;

@protocol RJCreateChoreographedClassTrackCellDelegate <NSObject>

- (void)createChoreographedClassTrackCellDownButtonPressed:(RJCreateChoreographedClassTrackCell *)cell;
- (void)createChoreographedClassTrackCellTrackButtonPressed:(RJCreateChoreographedClassTrackCell *)cell;
- (void)createChoreographedClassTrackCellTrashButtonPressed:(RJCreateChoreographedClassTrackCell *)cell;
- (void)createChoreographedClassTrackCellUpButtonPressed:(RJCreateChoreographedClassTrackCell *)cell;

@end


@class RJParseTrack;

@interface RJCreateChoreographedClassTrackCell : UICollectionViewCell

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
