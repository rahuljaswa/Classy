//
//  RJAuthenticationViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJParseUser;

@interface RJAuthenticationViewController : UIViewController

+ (instancetype)sharedInstance;

- (void)logOutWithCompletion:(void (^)(BOOL success))completion;
- (void)startWithPresentingViewController:(UIViewController *)viewController completion:(void (^)(RJParseUser *user))completion;

@end
