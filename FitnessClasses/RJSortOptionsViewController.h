//
//  RJSortOptionsViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/2/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryViewController.h"


@class RJParseCategory;
@class RJSortOptionsViewController;

@protocol RJSortOptionsViewControllerDelegate <NSObject>

- (void)sortOptionsViewController:(RJSortOptionsViewController *)sortOptionsViewController didSelectNewCategoryType:(RJParseCategoryType)categoryType;
- (void)sortOptionsViewController:(RJSortOptionsViewController *)sortOptionsViewController didSelectPopularCategoryType:(RJParseCategoryType)categoryType;
- (void)sortOptionsViewController:(RJSortOptionsViewController *)sortOptionsViewController didSelectCategory:(RJParseCategory *)category;

@end


@interface RJSortOptionsViewController : RJGalleryViewController

@property (nonatomic, assign) id<RJSortOptionsViewControllerDelegate> sortOptionsDelegate;

@end
