//
//  RJClassCommentsViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJChatTableViewController.h"


@class RJClassCommentsViewController;

@protocol RJClassCommentsViewControllerDelegate <NSObject>

- (void)classCommentsViewControllerDidPressSendButton:(RJClassCommentsViewController *)classCommentsViewController;

@end



@interface RJClassCommentsViewController : RJChatTableViewController

@property (nonatomic, weak) id<RJClassCommentsViewControllerDelegate> classCommentsDelegate;

- (void)setComments:(NSArray *)comments likes:(NSArray *)likes;

@end
