//
//  RJSettingsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAuthenticationViewController.h"
#import "RJCreateEditChoreographedClassViewController.h"
#import "RJCreateExerciseViewController.h"
#import "RJCreateEditSelfPacedClassViewController.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJSettingsViewController.h"
#import "RJCreditsHelper.h"
#import "RJStyleManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
@import MessageUI.MFMailComposeViewController;

static NSString *const kSettingsCellID = @"SettingsCellID";

typedef NS_ENUM(NSInteger, Section) {
    kSectionUserInfo,
    kSectionCredits,
    kSectionFeedback,
    kSectionLogout,
    kNumSections
};

typedef NS_ENUM(NSUInteger, UserInfoSectionRow) {
    kUserInfoSectionRowName,
    kUserInfoSectionRowPhoneNumber,
    kUserInfoSectionRowVersion,
    kUserInfoSectionRowAvailableCredits,
    kNumUserInfoSectionRows
};

typedef NS_ENUM(NSUInteger, CreditsSectionRow) {
    kCreditsSectionRowBuyCredits,
    kCreditsSectionRowEarnCredits,
    kNumCreditsSectionRows
};


@interface RJSettingsViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) RJParseUser *currentUser;

@end


@implementation RJSettingsViewController

#pragma mark - Private Properties

- (RJParseUser *)currentUser {
    return [RJParseUser currentUser];
}

#pragma mark - Private Protocols - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
        case kSectionCredits:
            numberOfRows = kNumCreditsSectionRows;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsCellID forIndexPath:indexPath];
    Section settingsSection = indexPath.section;
    switch (settingsSection) {
        case kSectionUserInfo: {
            UserInfoSectionRow userInfoSectionRow = indexPath.row;
            switch (userInfoSectionRow) {
                case kUserInfoSectionRowName:
                    cell.textLabel.text = self.currentUser.name;
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    break;
                case kUserInfoSectionRowPhoneNumber:
                    cell.textLabel.text = self.currentUser.username;
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    break;
                case kUserInfoSectionRowVersion:
                    cell.textLabel.text = [NSString stringWithFormat:@"Classy v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    break;
                case kUserInfoSectionRowAvailableCredits:
                    if (self.currentUser.creditsAvailable) {
                        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Credits Available", nil), self.currentUser.creditsAvailable];
                    } else {
                        cell.textLabel.text = NSLocalizedString(@"0 Credits Available", nil);
                    }
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    break;
                default:
                    break;
            }
            cell.userInteractionEnabled = NO;
            break;
        }
        case kSectionCredits: {
            CreditsSectionRow creditSectionRow = indexPath.row;
            switch (creditSectionRow) {
                case kCreditsSectionRowBuyCredits:
                    cell.textLabel.text = NSLocalizedString(@"Buy Credits", nil);
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    break;
                case kCreditsSectionRowEarnCredits:
                    cell.textLabel.text = NSLocalizedString(@"Earn Credits for Free", nil);
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    break;
                default:
                    break;
            }
            cell.userInteractionEnabled = YES;
            break;
        }
        case kSectionFeedback:
            cell.textLabel.text = NSLocalizedString(@"Send Feedback & Suggestions", nil);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = YES;
            break;
        case kSectionLogout:
            cell.textLabel.text = NSLocalizedString(@"Logout", nil);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = YES;
            break;
        default:
            break;
    }
    cell.textLabel.textColor = [RJStyleManager sharedInstance].themeTextColor;
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
        case kSectionCredits: {
            void (^completion) (BOOL) = ^(BOOL success) {
                if (success) {
                    [self.tableView reloadData];
                }
            };
            
            CreditsSectionRow creditSectionRow = indexPath.row;
            switch (creditSectionRow) {
                case kCreditsSectionRowBuyCredits: {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"How many credits would you like to buy?", nil) preferredStyle:UIAlertControllerStyleActionSheet];
                    
                    [alertController addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                    
                    __block RJCreditsHelper *creditsHelper = [RJCreditsHelper sharedInstance];
                    [alertController addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"1 Credit ($0.99)", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [creditsHelper purchaseCreditsPackage:kRJCreditsHelperCreditPackageOne completion:completion];
                    }]];
                    [alertController addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"5 Credits ($3.99)", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [creditsHelper purchaseCreditsPackage:kRJCreditsHelperCreditPackageFive completion:completion];
                    }]];
                    [alertController addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"10 Credits ($6.99)", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [creditsHelper purchaseCreditsPackage:kRJCreditsHelperCreditPackageTen completion:completion];
                    }]];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    break;
                }
                case kCreditsSectionRowEarnCredits: {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"You can earn free credits by helping to spread the word about Classy!", nil) preferredStyle:UIAlertControllerStyleActionSheet];
                    
                    [alertController addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                    
                    __block RJCreditsHelper *creditsHelper = [RJCreditsHelper sharedInstance];
                    
                    [alertController addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"Share on Twitter (1 credit)", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [creditsHelper earnCreditsOption:kRJCreditsHelperEarnCreditsOptionTwitterShare presentingViewController:self completion:completion];
                    }]];
                    [alertController addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"Share on Facebook (1 credit)", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [creditsHelper earnCreditsOption:kRJCreditsHelperEarnCreditsOptionFacebookShare presentingViewController:self completion:completion];
                    }]];
                    
                    if (self.currentUser.showAllEarnCreditsOptions) {
                        [alertController addAction:
                         [UIAlertAction actionWithTitle:NSLocalizedString(@"Write a 5-Star App Store Review (2 credits)", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            [creditsHelper earnCreditsOption:kRJCreditsHelperEarnCreditsOptionAppStoreReview presentingViewController:self completion:completion];
                        }]];
                    }

                    [self presentViewController:alertController animated:YES completion:nil];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:
     [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:
     [UIAlertAction actionWithTitle:NSLocalizedString(@"New Exercise", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RJCreateExerciseViewController *createViewController = [[RJCreateExerciseViewController alloc] init];
        [[self navigationController] pushViewController:createViewController animated:YES];
    }]];
    [alertController addAction:
     [UIAlertAction actionWithTitle:NSLocalizedString(@"New Self-Paced Workout", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RJCreateEditSelfPacedClassViewController *createViewController = [[RJCreateEditSelfPacedClassViewController alloc] init];
        [[self navigationController] pushViewController:createViewController animated:YES];
    }]];
    [alertController addAction:
     [UIAlertAction actionWithTitle:NSLocalizedString(@"New Choreographed Workout", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RJCreateEditChoreographedClassViewController *createViewController = [[RJCreateEditChoreographedClassViewController alloc] init];
        [[self navigationController] pushViewController:createViewController animated:YES];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
    
    if (self.currentUser.admin) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:item];
    }
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    self.tableView.separatorColor = styleManager.themeTextColor;
    self.tableView.backgroundColor = styleManager.themeBackgroundColor;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSettingsCellID];
    [[RJParseUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
        [self.tableView reloadData];
    }];
}

@end
