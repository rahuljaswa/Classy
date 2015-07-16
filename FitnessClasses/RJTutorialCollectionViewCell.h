//
//  RJTutorialCollectionViewCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/15/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJInsetLabel;

@interface RJTutorialCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) RJInsetLabel *textLabel;
@property (nonatomic, strong) RJInsetLabel *detailTextLabel;

@end
