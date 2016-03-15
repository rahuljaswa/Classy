//
//  RJAppDelegate.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/4/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAppDelegate.h"
#import "RJHomeNavigationViewController.h"
#import "RJImageCacheManager.h"
#import "RJInAppPurchaseHelper.h"
#import "RJInitialLoadingViewController.h"
#import "RJMixpanelHelper.h"
#import "RJParseTemplate.h"
#import "RJParseUser.h"
#import "RJStyleManager.h"
#import "RJTutorialViewController.h"
#import "RJUserDefaults.h"
#import "UIColor+RJAdditions.h"
#import <AVFoundation/AVFoundation.h>
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>
#import <Fabric/Fabric.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <Mixpanel/Mixpanel.h>
#import <Parse/Parse.h>


@interface RJAppDelegate () <RJInitialLoadingViewControllerDelegate, RJTutorialViewControllerDelegate>

@property (strong, nonatomic) RJHomeNavigationViewController *rootViewController;
@property (strong, nonatomic) RJImageCacheManager *imageCacheManager;

@end


@implementation RJAppDelegate

#pragma mark - Private Protocols - RJInitialLoadingViewControllerDelegate

- (void)initialLoadingViewControllerDidFinish:(RJInitialLoadingViewController *)initialLoadingViewController {
    [self updateMainUI];
}

#pragma mark - Private Protocols - RJTutorialViewControllerDelegate

- (void)tutorialViewControllerDidFinish:(RJTutorialViewController *)tutoralViewController {
    [RJUserDefaults saveDidShowTutorial];
    [self updateMainUI];
}

#pragma mark - Public Protocols - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[DigitsKit, CrashlyticsKit]];
    
    [Parse setApplicationId:@"TkGCid5iUjIT0ClgavtTgK34QyQeJfMMG5ZiHSlG"
                  clientKey:@"VaAAZQolPUkP98B8S5fdInr0MTtKSTYuqLHAw0dw"];
    
    [self setUpMixpanel];
    [self setUpAudioSession];
    [self setUpFastImageCache];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    if ([RJParseTemplate currentTemplate] && [RJParseUser currentUserWithSubscriptions]) {
        [self updateMainUI];
    } else {
        RJInitialLoadingViewController *initialLoadingViewController = [[RJInitialLoadingViewController alloc] initWithNibName:nil bundle:nil];
        initialLoadingViewController.delegate = self;
        self.window.rootViewController = initialLoadingViewController;
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    
    [RJMixpanelHelper trackForCurrentApp:kRJMixpanelConstantsOpenedApp];
    [[Mixpanel sharedInstance].people increment:kRJMixpanelPeopleConstantsAppOpens by:@1];
    
    [self clearAppBadge];
    
    if (self.window.rootViewController == self.rootViewController) {
        [self.rootViewController reloadWithCompletion:nil];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error updating current installation with device token: %@", error);
        }
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark - Private Instance Methods

- (void)clearAppBadge {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error clearing app badge: %@", error);
        }
    }];
}

#pragma mark - Private Instance Methods - Refresh

- (void)refreshCurrentUserSubscriptions {
    NSData *subscriptionReceipt = [RJUserDefaults subscriptionReceipt];
    if (subscriptionReceipt) {
        [[RJInAppPurchaseHelper sharedInstance] updateCurrentUserSubscriptionStatusWithReceiptData:subscriptionReceipt completion:nil];
    }
}

#pragma mark - Private Instance Methods - Setup

- (void)setUpAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
}

- (void)setUpFastImageCache {
    self.imageCacheManager = [[RJImageCacheManager alloc] init];
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    sharedImageCache.delegate = self.imageCacheManager;
    [sharedImageCache setFormats:[RJImageCacheManager formats]];
}

- (void)updateMainUI {
    if ([RJParseUser currentUserWithSubscriptions]) {
        [self refreshCurrentUserSubscriptions];
    }
    
    [self setUpStyleManager];
    [[RJStyleManager sharedInstance] applyGlobalStyles];
    
    
    UIViewController *newViewController = nil;
    if ([RJUserDefaults shouldShowTutorialOnLaunch]) {
        RJTutorialViewController *tutorial = [[RJTutorialViewController alloc] init];
        tutorial.tutorialDelegate = self;
        newViewController = tutorial;
    } else {
        _rootViewController = [[RJHomeNavigationViewController alloc] init];
        newViewController = _rootViewController;
    }
    
    if (self.window.rootViewController) {
        UIView *overlayView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
        [newViewController.view addSubview:overlayView];
        self.window.rootViewController = newViewController;
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            overlayView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [overlayView removeFromSuperview];
        }];
    } else {
        self.window.rootViewController = newViewController;
    }
}

- (void)setUpMixpanel {
    Mixpanel *sharedMixpanel = [Mixpanel sharedInstanceWithToken:kRJMixpanelConstantsToken];
    [sharedMixpanel identify:sharedMixpanel.distinctId];
}

- (void)setUpStyleManager {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    RJParseTemplate *template = [RJParseTemplate currentTemplate];
    
    if (template.themeAccentColor) {
        styleManager.accentColor = [UIColor colorForHexString:template.themeAccentColor];
    } else {
        styleManager.accentColor = [UIColor colorWithRed:12.0f/255.0f green:165.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    }
    
    if (template.themeBackgroundColor) {
        styleManager.themeBackgroundColor = [UIColor colorForHexString:template.themeBackgroundColor];
    } else {
        styleManager.themeBackgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
    
    if (template.themeTextColor) {
        styleManager.themeTextColor = [UIColor colorForHexString:template.themeTextColor];
    } else {
        styleManager.themeTextColor = [UIColor colorWithWhite:0.2 alpha:1.0f];
    }
    
    if (template.themeTitleColor) {
        styleManager.titleColor = [UIColor colorForHexString:template.themeTitleColor];
    } else {
        styleManager.titleColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    }
    
    styleManager.maskColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
    
    styleManager.tintBlueColor = [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    styleManager.tintLightGrayColor = [UIColor colorWithWhite:0.92 alpha:1.0f];
    
    styleManager.navigationBarFont = [UIFont fontWithName:@"Avenir-Heavy" size:18.0f];
    
    styleManager.giantBoldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:60.0f];
    styleManager.giantFont = [UIFont fontWithName:@"Helvetica-Light" size:60.0f];
    styleManager.largeBoldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30.0f];
    styleManager.largeFont = [UIFont fontWithName:@"Helvetica-Light" size:30.0f];
    styleManager.mediumBoldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
    styleManager.mediumFont = [UIFont fontWithName:@"Helvetica-Light" size:20.0f];
    styleManager.smallBoldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    styleManager.smallFont = [UIFont fontWithName:@"Helvetica-Light" size:15.0f];
    styleManager.verySmallBoldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f];
    styleManager.verySmallFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
    styleManager.tinyBoldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.0f];
    styleManager.tinyFont = [UIFont fontWithName:@"Helvetica-Light" size:10.0f];
}

@end
