//
//  RJHomeNavigationViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/7/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJPlayingClassViewController.h"
#import "RJHomeNavigationViewController.h"
#import "RJHomeViewController.h"
#import "RJParseClass.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJPlayingClassNavigationController.h"
#import "RJPurchaseSubscriptionViewController.h"
#import "RJTransparentNavigationBarController.h"
#import <SVProgressHUD/SVProgressHUD.h>


@interface RJHomeNavigationViewController () <RJHomeViewControllerDelegate, RJPlayingClassViewControllerDelegate, RJPurchaseSubscriptionViewControllerDelegate>

@property (nonatomic, copy) void (^subscriptionCompletion) (BOOL);
@property (nonatomic, strong, readonly) RJPlayingClassNavigationController *currentClassViewController;

@end


@implementation RJHomeNavigationViewController

@synthesize currentClassViewController = _currentClassViewController;

#pragma mark - Private Properties

- (RJPlayingClassNavigationController *)currentClassViewController {
    if (!_currentClassViewController) {
        _currentClassViewController = [[RJPlayingClassNavigationController alloc] init];
        _currentClassViewController.playingClassViewController.delegate = self;
    }
    return _currentClassViewController;
}

#pragma mark - Private Protocols - RJPurchaseSubscriptionViewControllerDelegate

- (void)purchaseSubscriptionViewControllerDidCancel:(RJPurchaseSubscriptionViewController *)purchaseSubscriptionViewController {
    [purchaseSubscriptionViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.subscriptionCompletion) {
        self.subscriptionCompletion(NO);
    }
}

- (void)purchaseSubscriptionViewControllerDidComplete:(RJPurchaseSubscriptionViewController *)purchaseSubscriptionViewController {
    [purchaseSubscriptionViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.subscriptionCompletion) {
        self.subscriptionCompletion(YES);
    }
}

#pragma mark - Private Protocols - RJPlayingClassViewControllerDelegate

- (void)playingClassViewController:(RJPlayingClassViewController *)playingClassViewController delegateWillMinimize:(BOOL)minimize {
    CGRect frame = minimize ? [self minimizedFrameForCurrentClassViewController] : [self maximizedFrameForCurrentClassViewController];
    [self animateClassViewControllerWithFinalFrame:frame completion:nil];
}

#pragma mark - Private Protocols - RJHomeViewControllerDelegate

- (void)homeViewController:(RJHomeViewController *)homeViewController wantsPlayForClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay {
    RJParseUser *currentUser = [RJParseUser currentUserWithSubscriptions];
    
    if ((currentUser && klass.requiresSubscription && [currentUser hasCurrentSubscription]) ||
        !klass.requiresSubscription)
    {
        [self startClass:klass autoPlay:autoPlay];
    } else {
        __weak RJHomeNavigationViewController *weakSelf = self;
        self.subscriptionCompletion = ^(BOOL success) {
            if (success) {
                [weakSelf startClass:klass autoPlay:autoPlay];
            }
        };
        
        RJPurchaseSubscriptionViewController *subscriptionViewController = [[RJPurchaseSubscriptionViewController alloc] initWithNibName:nil bundle:nil];
        subscriptionViewController.delegate = self;
        
        RJTransparentNavigationBarController *subscriptionNavigationController = [[RJTransparentNavigationBarController alloc] initWithRootViewController:subscriptionViewController];
        [self presentViewController:subscriptionNavigationController animated:YES completion:nil];
    }
}

#pragma mark - Private Instance Methods - Animation

- (void)presentPlayingClassViewController {
    self.currentClassViewController.playingClassViewController.minimized = NO;
    [self animateClassViewControllerWithFinalFrame:[self maximizedFrameForCurrentClassViewController] completion:nil];
}

- (void)animateClassViewControllerWithFinalFrame:(CGRect)frame completion:(void (^)(void))completion {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.currentClassViewController.view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

#pragma mark - Private Instance Methods

- (void)startClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay {
    if ([klass isEqual:self.currentClassViewController.playingClassViewController.klass]) {
        [self presentPlayingClassViewController];
    } else {
        if (self.currentClassViewController.playingClassViewController.klass && self.currentClassViewController.playingClassViewController.hasClassStarted) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Are you sure you want to switch from your current workout?", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:
             [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.currentClassViewController.playingClassViewController setKlass:klass withAutoPlay:autoPlay];
                [self presentPlayingClassViewController];
            }]];
            [alertController addAction:
             [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            BOOL shouldPresent = !!self.currentClassViewController.playingClassViewController.klass;
            [self.currentClassViewController.playingClassViewController setKlass:klass withAutoPlay:autoPlay];
            if (shouldPresent) {
                [self presentPlayingClassViewController];
            }
        }
    }
}

- (CGRect)maximizedFrameForCurrentClassViewController {
    CGFloat topAdjustment = 20.0f;//self.currentClassViewController.topLayoutGuide.length;
    CGRect frame = self.view.bounds;
    frame.origin.y = topAdjustment;
    frame.size.height -= topAdjustment;
    return frame;
}

- (CGRect)minimizedFrameForCurrentClassViewController {
    CGRect frame = self.view.bounds;
    frame.origin.y = CGRectGetMaxY(frame)-40.0f;
    return frame;
}

#pragma mark - Public Instance Methods

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

- (instancetype)init {
    RJHomeViewController *homeViewController = [[RJHomeViewController alloc] init];
    homeViewController.delegate = self;
    homeViewController.navigationItem.hidesBackButton = YES;
    self = [super initWithRootViewController:homeViewController];
    if (self) {
        _homeViewController = homeViewController;
    }
    return self;
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [self.homeViewController reloadWithCompletion:completion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.currentClassViewController];
    self.currentClassViewController.playingClassViewController.minimized = YES;
    self.currentClassViewController.view.frame = [self minimizedFrameForCurrentClassViewController];
    [self.view addSubview:self.currentClassViewController.view];
}

@end
