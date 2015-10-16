//
//  RJPurchaseSubscriptionViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 10/4/15.
//  Copyright © 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAuthenticationViewController.h"
#import "RJInAppPurchaseHelper.h"
#import "RJInsetLabel.h"
#import "RJMixpanelHelper.h"
#import "RJParseUser.h"
#import "RJPurchaseSubscriptionViewController.h"
#import "RJStyleManager.h"
#import "RJUserDefaults.h"
#import "UIBarButtonItem+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kCellID = @"CellID";
static const CGFloat kTableViewHeight = 110.0f;

typedef NS_ENUM(NSInteger, PremiumFeature) {
    kPremiumFeatureUnlockContent,
    kPremiumFeatureUpdates,
    kNumPremiumFeatures
};


@interface RJPurchaseSubscriptionViewController () <UITableViewDataSource>

@property (nonatomic, strong, readonly) RJInsetLabel *detailLabel;
@property (nonatomic, strong, readonly) UIImageView *icon;
@property (nonatomic, strong, readonly) UIButton *monthlyButton;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) RJInsetLabel *titleLabel;
@property (nonatomic, strong, readonly) UIButton *yearlyButton;

@end


@implementation RJPurchaseSubscriptionViewController

#pragma mark - Private Protocols - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumPremiumFeatures;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    PremiumFeature feature = indexPath.row;
    switch (feature) {
        case kPremiumFeatureUnlockContent:
            cell.textLabel.text = NSLocalizedString(@"\u2022 Unlimited access to all workouts, classes, and other content.", nil);
            break;
        case kPremiumFeatureUpdates:
            cell.textLabel.text = NSLocalizedString(@"\u2022 Get updated workouts, programs, and advice.", nil);
            break;
        default:
            break;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [RJStyleManager sharedInstance].smallFont;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Private Instance Methods

- (void)cancelButtonPressed:(UIBarButtonItem *)barButtonItem {
    if ([self.delegate respondsToSelector:@selector(purchaseSubscriptionViewControllerDidCancel:)]) {
        [self.delegate purchaseSubscriptionViewControllerDidCancel:self];
    }
}

- (void)monthlyButtonPressed:(UIButton *)button {
    void (^purchaseSubscriptionBlock) (void) = ^{
        [[RJInAppPurchaseHelper sharedInstance] purchaseMonthlySubscriptionWithCompletion:^(BOOL success) {
            if (success) {
                NSData *receiptData = [RJUserDefaults subscriptionReceipt];
                if (receiptData) {
                    [[RJInAppPurchaseHelper sharedInstance] updateCurrentUserSubscriptionStatusWithReceiptData:receiptData completion:^(BOOL success) {
                        if ([self.delegate respondsToSelector:@selector(purchaseSubscriptionViewControllerDidComplete:)]) {
                            [self.delegate purchaseSubscriptionViewControllerDidComplete:self];
                        }
                    }];
                }
            }
        }];
    };
    
    if ([RJParseUser currentUser]) {
        purchaseSubscriptionBlock();
    } else {
        [[RJAuthenticationViewController sharedInstance] startWithPresentingViewController:self completion:^(RJParseUser *user) {
            [self dismissViewControllerAnimated:YES completion:nil];
            if (user && ![user hasCurrentSubscription]) {
                purchaseSubscriptionBlock();
            } else if ([user hasCurrentSubscription]) {
                [SVProgressHUD showWithStatus:NSLocalizedString(@"You are already a subscriber!", nil)];
                if ([self.delegate respondsToSelector:@selector(purchaseSubscriptionViewControllerDidComplete:)]) {
                    [self.delegate purchaseSubscriptionViewControllerDidComplete:self];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login failed. Try again!", nil)];
            }
        }];
    }
}

- (void)yearlyButtonPressed:(UIButton *)button {
    void (^purchaseSubscriptionBlock) (void) = ^{
        [[RJInAppPurchaseHelper sharedInstance] purchaseYearlySubscriptionWithCompletion:^(BOOL success) {
            if (success) {
                NSData *receiptData = [RJUserDefaults subscriptionReceipt];
                if (receiptData) {
                    [[RJInAppPurchaseHelper sharedInstance] updateCurrentUserSubscriptionStatusWithReceiptData:receiptData completion:^(BOOL success) {
                        if ([self.delegate respondsToSelector:@selector(purchaseSubscriptionViewControllerDidComplete:)]) {
                            [self.delegate purchaseSubscriptionViewControllerDidComplete:self];
                        }
                    }];
                }
            }
        }];
    };
    
    if ([RJParseUser currentUser]) {
        purchaseSubscriptionBlock();
    } else {
        [[RJAuthenticationViewController sharedInstance] startWithPresentingViewController:self completion:^(RJParseUser *user) {
            [self dismissViewControllerAnimated:YES completion:nil];
            if (user && ![user hasCurrentSubscription]) {
                purchaseSubscriptionBlock();
            } else if ([user hasCurrentSubscription]) {
                [SVProgressHUD showWithStatus:NSLocalizedString(@"You are already a subscriber!", nil)];
                if ([self.delegate respondsToSelector:@selector(purchaseSubscriptionViewControllerDidComplete:)]) {
                    [self.delegate purchaseSubscriptionViewControllerDidComplete:self];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login failed. Try again!", nil)];
            }
        }];
    }
}

- (void)updateButtonText {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    [[RJInAppPurchaseHelper sharedInstance] getSubscriptionPricesWithCompletion:^(double monthlyPrice, NSString *formattedMonthlyPrice, double yearlyPrice, NSString *formattedYearlyPrice) {
        if (formattedMonthlyPrice) {
            NSMutableAttributedString *monthlyAttributedString = [[NSMutableAttributedString alloc] init];
            [monthlyAttributedString appendAttributedString:
             [[NSAttributedString alloc] initWithString:[formattedMonthlyPrice uppercaseString] attributes:
              @{
                NSForegroundColorAttributeName : styleManager.accentColor,
                NSFontAttributeName : styleManager.mediumBoldFont
                }
              ]
             ];
            [monthlyAttributedString appendAttributedString:
             [[NSAttributedString alloc] initWithString:[NSLocalizedString(@" / Mo", nil) uppercaseString] attributes:
              @{
                NSForegroundColorAttributeName : styleManager.accentColor,
                NSFontAttributeName : styleManager.smallFont
                }
              ]
             ];
            [self.monthlyButton setAttributedTitle:monthlyAttributedString forState:UIControlStateNormal];
        }
        
        if (formattedYearlyPrice) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            
            NSMutableAttributedString *yearlyAttributedString = [[NSMutableAttributedString alloc] init];
            [yearlyAttributedString appendAttributedString:
             [[NSAttributedString alloc] initWithString:[formattedYearlyPrice uppercaseString] attributes:
              @{
                NSForegroundColorAttributeName : styleManager.accentColor,
                NSFontAttributeName : styleManager.mediumBoldFont,
                NSParagraphStyleAttributeName : style
                }
              ]
             ];
            [yearlyAttributedString appendAttributedString:
             [[NSAttributedString alloc] initWithString:[NSLocalizedString(@" / Yr", nil) uppercaseString] attributes:
              @{
                NSForegroundColorAttributeName : styleManager.accentColor,
                NSFontAttributeName : styleManager.smallFont,
                NSParagraphStyleAttributeName : style
                }
              ]
             ];
            NSInteger percentSavings = floor(((1-yearlyPrice/(monthlyPrice*12))*100));
            NSString *savingsString = [NSString stringWithFormat:NSLocalizedString(@"\nSave %lu%%", nil), (unsigned long)percentSavings];
            [yearlyAttributedString appendAttributedString:
             [[NSAttributedString alloc] initWithString:[savingsString uppercaseString] attributes:
              @{
                NSForegroundColorAttributeName : styleManager.accentColor,
                NSFontAttributeName : styleManager.smallFont,
                NSParagraphStyleAttributeName : style
                }
              ]
             ];
            [self.yearlyButton setAttributedTitle:yearlyAttributedString forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _detailLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _icon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _monthlyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _yearlyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *detailLabel = self.detailLabel;
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:detailLabel];
    UIView *icon = self.icon;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:icon];
    UIView *monthlyButton = self.monthlyButton;
    monthlyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:monthlyButton];
    UIView *tableView = self.tableView;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    UIView *titleLabel = self.titleLabel;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    UIView *yearlyButton = self.yearlyButton;
    yearlyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:yearlyButton];

    NSDictionary *views = NSDictionaryOfVariableBindings(detailLabel, icon, monthlyButton, tableView, titleLabel, yearlyButton);
    NSDictionary *metrics = @{
                              @"t_margin" : @(55.0f),
                              @"b_margin" : @(20.0f),
                              @"side_spacing" : @(20.0f),
                              @"buttons_height" : @(46.0f),
                              @"tableView_height" : @(kTableViewHeight),
                              @"tableView_marginTop" : @(30.0f),
                              };
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-t_margin-[icon][titleLabel][detailLabel]-tableView_marginTop-[tableView(tableView_height)]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[monthlyButton(buttons_height)]-b_margin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yearlyButton(buttons_height)]-b_margin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-side_spacing-[icon]-side_spacing-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-side_spacing-[titleLabel]-side_spacing-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-side_spacing-[detailLabel]-side_spacing-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-side_spacing-[tableView]-side_spacing-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-side_spacing-[monthlyButton]-side_spacing-[yearlyButton(==monthlyButton)]-side_spacing-|" options:0 metrics:metrics views:views]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RJMixpanelHelper trackForCurrentApp:kRJMixpanelConstantsViewedSubscriptionPage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem cancelBarButtonItemWithTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:[UIColor whiteColor]];
    
    [self updateButtonText];
    self.titleLabel.text = NSLocalizedString(@"Classy Plus", nil);
    self.detailLabel.text = NSLocalizedString(@"Unlock the healthy, happy, beautiful, version of you.", nil);
    
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    self.view.backgroundColor = styleManager.accentColor;
    self.icon.image = [UIImage tintableImageNamed:@"appIcon"];
    self.icon.contentMode = UIViewContentModeScaleAspectFit;
    self.icon.tintColor = [UIColor whiteColor];
    self.titleLabel.insets = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = styleManager.largeBoldFont;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.detailLabel.insets = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
    self.detailLabel.textColor = [UIColor whiteColor];
    self.detailLabel.font = styleManager.mediumFont;
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tableView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.tableView.layer.cornerRadius = 3.0f;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = kTableViewHeight/kNumPremiumFeatures;
    [self.monthlyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.0f alpha:0.7f]] forState:UIControlStateNormal];
    [self.monthlyButton addTarget:self action:@selector(monthlyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.monthlyButton setTitleColor:styleManager.accentColor forState:UIControlStateNormal];
    self.monthlyButton.clipsToBounds = YES;
    self.monthlyButton.layer.cornerRadius = 5.0f;
    self.monthlyButton.titleLabel.numberOfLines = 0;
    [self.yearlyButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.yearlyButton addTarget:self action:@selector(yearlyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.yearlyButton setTitleColor:styleManager.accentColor forState:UIControlStateNormal];
    self.yearlyButton.clipsToBounds = YES;
    self.yearlyButton.layer.cornerRadius = 5.0f;
    self.yearlyButton.titleLabel.numberOfLines = 0;
}

@end
