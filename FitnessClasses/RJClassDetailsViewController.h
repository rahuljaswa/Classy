//
//  RJClassDetailsViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJClassDetailsViewController;

@protocol RJClassDetailsViewControllerDelegate <NSObject>

- (void)classDetailsViewControllerDidPressPlayButton:(RJClassDetailsViewController *)classDetailsViewController;

@end


@class RJParseClass;

@interface RJClassDetailsViewController : UIViewController

@property (nonatomic, weak) id<RJClassDetailsViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL showsPlayButton;
@property (nonatomic, strong) RJParseClass *klass;


@end
