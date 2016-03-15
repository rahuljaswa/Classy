//
//  RJClassSummaryView.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RJClassSummaryView : UIView

@property (nonatomic, strong, readonly) UILabel *classTitle;
@property (nonatomic, strong, readonly) UIButton *playPauseButton;
@property (nonatomic, strong, readonly) UILabel *track;
@property (nonatomic, strong, readonly) UIImageView *trackArtwork;

@end
