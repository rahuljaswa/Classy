//
//  RJCreateCategoryViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/31/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateCategoryViewController;

@protocol RJCreateCategoryViewControllerDelegate <NSObject>

- (void)createCategoryViewControllerDidCreateCategory:(RJCreateCategoryViewController *)createCategoryViewController;

@end


@interface RJCreateCategoryViewController : UICollectionViewController

@property (nonatomic, weak) id<RJCreateCategoryViewControllerDelegate> createDelegate;

@end
