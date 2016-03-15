//
//  RJTutorialViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/15/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJTutorialViewController;

@protocol RJTutorialViewControllerDelegate <NSObject>

- (void)tutorialViewControllerDidFinish:(RJTutorialViewController *)tutoralViewController;

@end


@interface RJTutorialViewController : UICollectionViewController

@property (nonatomic, weak) id<RJTutorialViewControllerDelegate> tutorialDelegate;

@end
