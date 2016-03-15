//
//  RJInitialLoadingViewController.h
//  Pods
//
//  Created by Rahul Jaswa on 10/24/15.
//
//

#import <UIKit/UIKit.h>


@class RJInitialLoadingViewController;

@protocol RJInitialLoadingViewControllerDelegate <NSObject>

- (void)initialLoadingViewControllerDidFinish:(RJInitialLoadingViewController *)initialLoadingViewController;

@end


@interface RJInitialLoadingViewController : UIViewController

@property (nonatomic, weak) id<RJInitialLoadingViewControllerDelegate> delegate;

@end
