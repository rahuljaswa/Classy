//
//  RJPurchaseSubscriptionViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 10/4/15.
//  Copyright © 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJPurchaseSubscriptionViewController;

@protocol RJPurchaseSubscriptionViewControllerDelegate <NSObject>

- (void)purchaseSubscriptionViewControllerDidCancel:(RJPurchaseSubscriptionViewController *)purchaseSubscriptionViewController;
- (void)purchaseSubscriptionViewControllerDidComplete:(RJPurchaseSubscriptionViewController *)purchaseSubscriptionViewController;

@end


@interface RJPurchaseSubscriptionViewController : UIViewController

@property (nonatomic, weak) id<RJPurchaseSubscriptionViewControllerDelegate> delegate;

@end
