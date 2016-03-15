//
//  RJHomeViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/2/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJHomeViewController;
@class RJParseClass;

@protocol RJHomeViewControllerDelegate <NSObject>

- (void)homeViewController:(RJHomeViewController *)homeViewController wantsPlayForClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay;

@end


@interface RJHomeViewController : UIViewController

@property (nonatomic, weak) id<RJHomeViewControllerDelegate> delegate;

- (void)reloadWithCompletion:(void (^)(BOOL success))completion;

@end
