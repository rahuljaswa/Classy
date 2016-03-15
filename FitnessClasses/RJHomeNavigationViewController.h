//
//  RJHomeNavigationViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/7/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJHomeViewController;

@interface RJHomeNavigationViewController : UINavigationController

@property (nonatomic, strong, readonly) RJHomeViewController *homeViewController;

- (void)reloadWithCompletion:(void (^)(BOOL))completion;

@end
