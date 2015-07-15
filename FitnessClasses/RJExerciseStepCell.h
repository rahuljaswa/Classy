//
//  RJExerciseStepCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJInsetLabel;

@interface RJExerciseStepCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *image;
@property (nonatomic, strong, readonly) RJInsetLabel *textLabel;

@end
