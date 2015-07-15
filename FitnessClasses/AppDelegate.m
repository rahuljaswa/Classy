//
//  AppDelegate.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/4/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "AppDelegate.h"
#import "RJHomeNavigationViewController.h"
#import "RJImageCacheManager.h"
#import "RJMixpanelConstants.h"
#import "RJStyleManager.h"
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>
#import <Fabric/Fabric.h>
#import <Mixpanel/Mixpanel.h>
#import <Parse/Parse.h>
@import AVFoundation.AVAudioSession;


@interface AppDelegate ()

@property (strong, nonatomic) RJHomeNavigationViewController *rootViewController;
@property (strong, nonatomic) RJImageCacheManager *imageCacheManager;

@end


@implementation AppDelegate

#pragma mark - Private Properties

- (RJHomeNavigationViewController *)rootViewController {
    if (!_rootViewController) {
        _rootViewController = [[RJHomeNavigationViewController alloc] init];
    }
    return _rootViewController;
}

#pragma mark - Public Protocols - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[DigitsKit, CrashlyticsKit]];
    
    [Parse setApplicationId:@"TkGCid5iUjIT0ClgavtTgK34QyQeJfMMG5ZiHSlG"
                  clientKey:@"VaAAZQolPUkP98B8S5fdInr0MTtKSTYuqLHAw0dw"];
    
    [self setUpMixpanel];
    [self setUpAudioSession];
    [self setUpFastImageCache];
    [self setUpStyleManager];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    [[RJStyleManager sharedInstance] applyGlobalStyles];
    
    self.window.rootViewController = self.rootViewController;
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.rootViewController reloadWithCompletion:nil];

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:kRJMixpanelConstantsOpenedApp];
    [mixpanel.people increment:kRJMixpanelPeopleConstantsAppOpens by:@1];
    
    [self clearAppBadge];
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

- (void)setUpMixpanel {
    Mixpanel *sharedMixpanel = [Mixpanel sharedInstanceWithToken:kRJMixpanelConstantsToken];
    [sharedMixpanel identify:sharedMixpanel.distinctId];
}

- (void)setUpStyleManager {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    styleManager.accentColor = [UIColor colorWithRed:45.0f/255.0f green:249.0f/255.0f blue:188.0f/255.0f alpha:1.0f];
    styleManager.maskColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    styleManager.themeBackgroundColor = [UIColor colorWithRed:31.0f/255.0f green:38.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    styleManager.themeTextColor = [UIColor whiteColor];
    styleManager.titleColor = [UIColor whiteColor];
    
    styleManager.tintBlueColor = [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    styleManager.tintLightGrayColor = [UIColor colorWithWhite:0.92 alpha:1.0f];
    
    styleManager.contrastOneLevelColor = [UIColor whiteColor];
    styleManager.contrastTwoLevelsColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    
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
}

@end
