//
//  RJGalleryCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJInsetLabel;

@interface RJGalleryCell : UICollectionViewCell

@property (nonatomic, strong) UIView *accessoriesView;

@property (nonatomic, strong, readonly) RJInsetLabel *title;
@property (nonatomic, strong, readonly) UIImageView *image;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinner;

@property (nonatomic, assign, getter = shouldDisableDuringLoading) BOOL disableDuringLoading;
@property (nonatomic, assign, getter = shouldMask) BOOL mask;
@property (nonatomic, assign, getter = shouldHaveSelectedTitle) BOOL haveSelectedTitle;

@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *selectedTitleBackgroundColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIColor *unselectedTitleColor;
@property (nonatomic, strong) UIColor *unselectedTitleBackgroundColor;

@end
