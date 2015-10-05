//
//  RJAuthenticationDetailsViewController.h
//  NINEXX
//
//  Created by Rahul Jaswa on 6/10/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJAuthenticationDetailsViewController;

@protocol RJAuthenticationDetailsViewControllerDelegate <NSObject>

- (void)authenticationDetailsViewControllerDidCancel:(RJAuthenticationDetailsViewController *)viewController;
- (void)authenticationDetailsViewControllerDidFinish:(RJAuthenticationDetailsViewController *)viewController;

@end


@interface RJAuthenticationDetailsViewController : UITableViewController

@property (weak, nonatomic) id<RJAuthenticationDetailsViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;

@end
