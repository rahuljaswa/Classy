//
//  RJSortOptionsViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/2/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJParseCategory;
@class RJSortOptionsViewController;

@protocol RJSortOptionsViewControllerDelegate <NSObject>

- (void)sortOptionsViewController:(RJSortOptionsViewController *)sortOptionsViewController didSelectCategory:(RJParseCategory *)category;

@end


@interface RJSortOptionsViewController : UICollectionViewController

@property (nonatomic, assign) id<RJSortOptionsViewControllerDelegate> sortOptionsDelegate;

@end
