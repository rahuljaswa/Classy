//
//  RJCreateEditChoreographedClassTimeline.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/29/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RJCreateEditChoreographedClassTimeline : UICollectionReusableView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIColor *labelBackgroundColor;
@property (nonatomic, assign) UIEdgeInsets labelInsets;

+ (NSString *)kind;

@end
