//
//  RJSettingsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAuthenticationViewController.h"
#import "RJCreatableObjectsViewController.h"
#import "RJInAppPurchaseHelper.h"
#import "RJParseSubscription.h"
#import "RJParseTemplate.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJPurchaseSubscriptionViewController.h"
#import "RJSettingsViewController.h"
#import "RJStyleManager.h"
#import "RJTransparentNavigationBarController.h"
#import "RJUserDefaults.h"
#import <MessageUI/MessageUI.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kSettingsCellID = @"SettingsCellID";

typedef NS_ENUM(NSInteger, Section) {
    kSectionUserInfo,
    kSectionSubscription,
    kSectionFeedback,
    kSectionLogout,
    kNumSections
};

typedef NS_ENUM(NSUInteger, UserInfoSectionRow) {
    kUserInfoSectionRowName,
    kUserInfoSectionRowPhoneNumber,
    kUserInfoSectionRowVersion,
    kUserInfoSectionRowSubscriptionStatus,
    kNumUserInfoSectionRows
};

typedef NS_ENUM(NSUInteger, SubscriptionSectionRow) {
//    kSubscriptionSectionRowEarnBonus,
    kSubscriptionSectionRowRestorePurchases,
    kSubscriptionSectionRowSubscribeOrCancelSubscription,
    kNumSubscriptionSectionRows
};


@interface RJSettingsViewController () <MFMailComposeViewControllerDelegate, RJPurchaseSubscriptionViewControllerDelegate>

@property (nonatomic, strong) RJParseUser *currentUser;

@end


@implementation RJSettingsViewController

#pragma mark - Private Protocols - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Protocols - RJPurchaseSubscriptionViewControllerDelegate

- (void)purchaseSubscriptionViewControllerDidCancel:(RJPurchaseSubscriptionViewController *)purchaseSubscriptionViewController {
    [purchaseSubscriptionViewController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

- (void)purchaseSubscriptionViewControllerDidComplete:(RJPurchaseSubscriptionViewController *)purchaseSubscriptionViewController {
    [purchaseSubscriptionViewController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    Section settingsSection = section;
    switch (settingsSection) {
        case kSectionUserInfo:
            numberOfRows = kNumUserInfoSectionRows;
            break;
        case kSectionSubscription:
            numberOfRows = kNumSubscriptionSectionRows;
            break;
        case kSectionFeedback:
            numberOfRows = 1;
            break;
        case kSectionLogout:
            numberOfRows = 1;
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsCellID forIndexPath:indexPath];
    Section settingsSection = indexPath.section;
    switch (settingsSection) {
        case kSectionUserInfo: {
            UserInfoSectionRow userInfoSectionRow = indexPath.row;
            switch (userInfoSectionRow) {
                case kUserInfoSectionRowName:
                    cell.textLabel.text = self.currentUser.name;
                    break;
                case kUserInfoSectionRowPhoneNumber:
                    cell.textLabel.text = self.currentUser.username;
                    break;
                case kUserInfoSectionRowVersion:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ v%@", [[RJParseTemplate currentTemplate] name], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
                    break;
                case kUserInfoSectionRowSubscriptionStatus:
                    if ([self.currentUser hasCurrentSubscription]) {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        formatter.dateFormat = @"M/d/yyyy";
                        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Subscription Ends %@", nil), [formatter stringFromDate:[self.currentUser currentAppSubscription].expirationDate]];
                        cell.textLabel.text = text;
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"Free Plan", nil);
                    }
                default:
                    break;
            }
            cell.textLabel.textColor = styleManager.themeTextColor;
            cell.userInteractionEnabled = NO;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            break;
        }
        case kSectionSubscription: {
            SubscriptionSectionRow subscriptionSectionRow = indexPath.row;
            switch (subscriptionSectionRow) {
//                case kSubscriptionSectionRowEarnBonus:
//                    cell.textLabel.text = NSLocalizedString(@"Earn Free Subscription", nil);
//                    break;
                case kSubscriptionSectionRowRestorePurchases:
                    cell.textLabel.text = NSLocalizedString(@"Restore Previous Purchases", nil);
                    break;
                case kSubscriptionSectionRowSubscribeOrCancelSubscription:
                    if ([self.currentUser hasCurrentSubscription]) {
                        cell.textLabel.text = NSLocalizedString(@"Cancel Subscription", nil);
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"Buy Subscription", nil);
                    }
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    break;
                default:
                    break;
            }
            cell.textLabel.textColor = styleManager.tintBlueColor;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = YES;
            break;
        }
        case kSectionFeedback:
            cell.textLabel.text = NSLocalizedString(@"Send Feedback & Suggestions", nil);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = styleManager.tintBlueColor;
            break;
        case kSectionLogout:
            cell.textLabel.text = NSLocalizedString(@"Logout", nil);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor redColor];
            cell.userInteractionEnabled = YES;
            break;
        default:
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Public Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Section settingsSection = indexPath.section;
    switch (settingsSection) {
        case kSectionUserInfo:
            break;
        case kSectionSubscription: {
            SubscriptionSectionRow subscriptionRow = indexPath.row;
            switch (subscriptionRow) {
                case kSubscriptionSectionRowSubscribeOrCancelSubscription: {
                    if ([self.currentUser hasCurrentSubscription]) {
                        UIApplication *application = [UIApplication sharedApplication];
                        NSURL *url = [NSURL URLWithString:@"https://support.apple.com/en-us/HT202039"];
                        if ([application canOpenURL:url]) {
                            [application openURL:url];
                        }
                    } else {
                        RJPurchaseSubscriptionViewController *subscriptionViewController = [[RJPurchaseSubscriptionViewController alloc] initWithNibName:nil bundle:nil];
                        subscriptionViewController.delegate = self;
                        
                        RJTransparentNavigationBarController *subscriptionNavigationController = [[RJTransparentNavigationBarController alloc] initWithRootViewController:subscriptionViewController];
                        [self presentViewController:subscriptionNavigationController animated:YES completion:nil];
                    }
                    break;
                }
                case kSubscriptionSectionRowRestorePurchases: {
                    RJInAppPurchaseHelper *inAppPurchaseHelper = [RJInAppPurchaseHelper sharedInstance];
                    [inAppPurchaseHelper restoreCompletedTransactionsWithCompletion:^(BOOL success) {
                        NSData *subscriptionReceipt = [RJUserDefaults subscriptionReceipt];
                        if (subscriptionReceipt) {
                            [inAppPurchaseHelper updateCurrentUserSubscriptionStatusWithReceiptData:subscriptionReceipt completion:^(BOOL success) {
                                [self.tableView reloadData];
                                [SVProgressHUD dismiss];
                            }];
                        }
                    }];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case kSectionFeedback: {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.mailComposeDelegate = self;
            [mailComposeViewController setToRecipients:@[@"r@getclassy.co"]];
            [mailComposeViewController setSubject:NSLocalizedString(@"Feedback", nil)];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
            break;
        }
        case kSectionLogout: {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging out...", nil)];
            [[RJAuthenticationViewController sharedInstance] logOutWithCompletion:^(BOOL success) {
                if (success) {
                    [[self navigationController] popViewControllerAnimated:YES];
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Logged out!", nil)];
                } else {
                    [SVProgressHUD dismiss];
                }
            }];
            break;
        }
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Instance Methods

- (void)createButtonPressed:(UIBarButtonItem *)barButtonItem {
    RJCreatableObjectsViewController *creatableObjectsViewController = [[RJCreatableObjectsViewController alloc] init];
    [[self navigationController] pushViewController:creatableObjectsViewController animated:YES];
}

#pragma mark - Public Instance Methods

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 40.0f, 0.0f);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.tableView.contentInset, insets)) {
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSLocalizedString(@"Settings", nil) uppercaseString];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    self.tableView.separatorColor = styleManager.themeTextColor;
    self.tableView.backgroundColor = styleManager.themeBackgroundColor;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSettingsCellID];
    
    self.currentUser = [RJParseUser currentUserWithSubscriptions];
    if (self.currentUser.admin) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:item];
    }
    [self.tableView reloadData];
}

@end
