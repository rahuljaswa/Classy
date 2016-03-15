//
//  RJCreateInstructorViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/31/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJCreateInstructorViewController;

@protocol RJCreateInstructorViewControllerDelegate <NSObject>

- (void)createInstructorViewControllerDidCreateInstructor:(RJCreateInstructorViewController *)createInstructorViewController;

@end


@interface RJCreateInstructorViewController : UICollectionViewController

@property (nonatomic, weak) id<RJCreateInstructorViewControllerDelegate> createDelegate;

@end

