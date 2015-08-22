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
#import "RJTutorialViewController.h"
#import "RJUserDefaults.h"
#import <SVProgressHUD/SVProgressHUD.h>


@interface RJHomeNavigationViewController () <RJHomeViewControllerDelegate, RJPlayingClassViewControllerDelegate, RJTutorialViewControllerDelegate>

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

#pragma mark - Private Protocols - RJTutorialViewControllerDelegate

- (void)tutorialViewControllerDidFinish:(RJTutorialViewController *)tutoralViewController {
    [RJUserDefaults saveDidShowTutorial];
    [[tutoralViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Protocols - RJPlayingClassViewControllerDelegate

- (void)playingClassViewController:(RJPlayingClassViewController *)playingClassViewController delegateWillMinimize:(BOOL)minimize {
    CGRect frame = minimize ? [self minimizedFrameForCurrentClassViewController] : [self maximizedFrameForCurrentClassViewController];
    [self animateClassViewControllerWithFinalFrame:frame completion:nil];
}

#pragma mark - Private Protocols - RJHomeViewControllerDelegate

- (void)homeViewController:(RJHomeViewController *)homeViewController wantsPlayForClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay {
    NSUInteger creditsCost = [klass.creditsCost integerValue];
    if (creditsCost > 0) {
        RJParseUser *user = [RJParseUser currentUser];
        if (user) {
            NSUInteger indexOfPurchasedClass = [user.classesPurchased indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [[(RJParseClass *)obj objectId] isEqualToString:klass.objectId];
            }];
            
            if (!user.classesPurchased || (indexOfPurchasedClass == NSNotFound)) {
                NSString *title = nil;
                if (creditsCost == 1) {
                    title = [NSString stringWithFormat:@"%@ costs 1 credit. You only have to pay once!", klass.name];
                } else {
                    title = [NSString stringWithFormat:@"%@ costs %@ credits. You only have to pay once!", klass.name, klass.creditsCost];
                }
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:
                 [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                [alertController addAction:
                 [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    if ([[[RJParseUser currentUser] creditsAvailable] unsignedIntegerValue] >= creditsCost) {
                        [SVProgressHUD showWithStatus:NSLocalizedString(@"Purchasing class...", nil) maskType:SVProgressHUDMaskTypeClear];
                        [RJParseUtils purchaseClass:klass completion:^(BOOL success) {
                            if (success) {
                                [self startClass:klass autoPlay:autoPlay];
                                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success!", nil) maskType:SVProgressHUDMaskTypeClear];
                            } else {
                                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error. Try again! You weren't charged.", nil)];
                            }
                        }];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Please earn or buy more credits (settings menu) to continue", nil)];
                    }
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                [self startClass:klass autoPlay:autoPlay];
            }
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"This class costs credits. Please login to earn or buy credits!", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:
             [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        [self startClass:klass autoPlay:autoPlay];
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
    if ([klass.objectId isEqualToString:self.currentClassViewController.playingClassViewController.klass.objectId]) {
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([RJUserDefaults shouldShowTutorialOnLaunch]) {
        RJTutorialViewController *tutorial = [[RJTutorialViewController alloc] init];
        tutorial.tutorialDelegate = self;
        [self presentViewController:tutorial animated:NO completion:nil];
    }
}

@end
