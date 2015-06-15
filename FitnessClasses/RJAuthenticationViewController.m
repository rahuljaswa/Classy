//
//  RJAuthenticationViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAuthenticationDetailsViewController.h"
#import "RJAuthenticationViewController.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"
#import "UIBarButtonItem+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <DigitsKit/DGTAppearance.h>
#import <DigitsKit/Digits.h>
#import <Mixpanel/Mixpanel.h>
#import <SVProgressHUD/SVProgressHUD.h>

typedef NS_ENUM(NSUInteger, UIState) {
    kUIStateNone,
    kUIStatePhoneVerification,
    kUIStateUsername,
};



@interface RJAuthenticationViewController () <RJAuthenticationDetailsViewControllerDelegate>

@property (nonatomic, strong, readonly) UILabel *descriptionLabel;
@property (nonatomic, strong, readonly) UIButton *startButton;

@property (nonatomic, assign) UIState state;

@property (nonatomic, strong) RJParseUser *user;

@property (nonatomic, strong) UIViewController *viewControllerForPresentation;

@property (nonatomic, copy) void (^completion) (RJParseUser *);

@end


@implementation RJAuthenticationViewController

#pragma mark - Private Properties

- (void)setState:(UIState)state {
    _state = state;
    switch (state) {
        case kUIStateNone:
            break;
        case kUIStatePhoneVerification: {
            DGTAppearance *appearance = [[DGTAppearance alloc] init];
            appearance.backgroundColor = [[RJStyleManager sharedInstance] themeColor];
            appearance.accentColor = [UIColor whiteColor];
            [[Digits sharedInstance] authenticateWithDigitsAppearance:appearance viewController:nil title:nil completion:^(DGTSession *session, NSError *error) {
                if (session) {
                    [SVProgressHUD showWithStatus:NSLocalizedString(@"Retrieving account details...", nil) maskType:SVProgressHUDMaskTypeClear];
                    [RJParseUser logInWithUsernameInBackground:session.phoneNumber
                                                      password:session.phoneNumber
                                                         block:^(PFUser *user, NSError *error)
                     {
                         if (user) {
                             self.user = (RJParseUser *)user;
                             if ([self.user.twitterDigitsUserID isEqualToString:session.userID]) {
                                 __weak RJAuthenticationViewController *weakSelf = self;
                                 [self updateInstallationForUser:self.user withCompletion:^(BOOL success) {
                                     __strong RJAuthenticationViewController *strongSelf = weakSelf;
                                     if (success) {
                                         strongSelf.state = kUIStateUsername;
                                     }
                                 }];
                             } else {
                                 self.user.twitterDigitsUserID = session.userID;
                                 [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                     __weak RJAuthenticationViewController *weakSelf = self;
                                     [self updateInstallationForUser:self.user withCompletion:^(BOOL success) {
                                         __strong RJAuthenticationViewController *strongSelf = weakSelf;
                                         if (success) {
                                             strongSelf.state = kUIStateUsername;
                                         }
                                     }];
                                 }];
                             }
                         } else {
                             [SVProgressHUD showWithStatus:NSLocalizedString(@"Creating account...", nil) maskType:SVProgressHUDMaskTypeClear];
                             self.user = [RJParseUser object];
                             self.user.username = session.phoneNumber;
                             self.user.password = session.phoneNumber;
                             self.user.twitterDigitsUserID = session.userID;
                             [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                 if (succeeded) {
                                     __weak RJAuthenticationViewController *weakSelf = self;
                                     [self updateInstallationForUser:self.user withCompletion:^(BOOL success) {
                                         __strong RJAuthenticationViewController *strongSelf = weakSelf;
                                         if (success) {
                                             strongSelf.state = kUIStateUsername;
                                         }
                                     }];
                                 } else {
                                     NSLog(@"Error signing up user\n\n%@", [error localizedDescription]);
                                 }
                             }];
                         }
                     }];
                }
            }];
            break;
        }
        case kUIStateUsername: {
            RJAuthenticationDetailsViewController *authenticationDetailsViewController = [[RJAuthenticationDetailsViewController alloc] init];
            authenticationDetailsViewController.delegate = self;
            authenticationDetailsViewController.title = [NSLocalizedString(@"Enter Display Name", nil) uppercaseString];
            authenticationDetailsViewController.textField.placeholder = NSLocalizedString(@"Display Name", nil);
            authenticationDetailsViewController.textField.keyboardType = UIKeyboardTypeAlphabet;
            authenticationDetailsViewController.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            if (self.user) {
                authenticationDetailsViewController.textField.text = self.user.name;
            } else {
                authenticationDetailsViewController.textField.text = nil;
            }
            [authenticationDetailsViewController.button setTitle:NSLocalizedString(@"Finish", nil) forState:UIControlStateNormal];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationDetailsViewController];
            [self presentViewController:navigationController animated:YES completion:^{
                [SVProgressHUD dismiss];
            }];
            break;
        }
    }
}

#pragma mark - Private Protocols

- (void)authenticationDetailsViewControllerDidCancel:(RJAuthenticationDetailsViewController *)viewController {
    [[viewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)authenticationDetailsViewControllerDidFinish:(RJAuthenticationDetailsViewController *)viewController {
    self.user.name = viewController.textField.text;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving name...", nil) maskType:SVProgressHUDMaskTypeClear];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self completeLogin];
        } else {
            NSLog(@"Error saving display name\n\n%@", [error localizedDescription]);
        }
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - Private Instance Methods

- (void)registerUserNotificationSettingsWithCompletion:(void (^)(void))completion {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeNone | UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    if (completion) {
        completion();
    }
}

- (void)registerRemoteNotificationSettingsWithCompletion:(void (^)(void))completion {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
    if (completion) {
        completion();
    }
}

- (void)completeLogin {
    [self registerUserNotificationSettingsWithCompletion:^{
        [self registerRemoteNotificationSettingsWithCompletion:^{
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel createAlias:self.user.objectId forDistinctID:mixpanel.distinctId];
            [mixpanel.people set:
             @{
               @"$username": self.user.name,
               @"$phone" : self.user.username
               }
             ];
            if (self.completion) {
                self.completion(self.user);
            }
        }];
    }];
}

- (void)updateInstallationForUser:(RJParseUser *)user withCompletion:(void (^)(BOOL success))completion {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    RJParseUser *currentUserOnInstallation = currentInstallation[@"user"];
    if (!currentUserOnInstallation) {
        currentInstallation[@"user"] = user;
    }
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error updating installation with user: %@", error);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

- (void)cancelButtonPressed:(UIButton *)button {
    [[Digits sharedInstance] logOut];
    [RJParseUser logOutInBackgroundWithBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error logging out user: %@", error);
        }
        if (self.completion) {
            self.completion(nil);
        }
        self.state = kUIStateNone;
    }];
}

- (void)startButtonPressed:(UIButton *)button {
    self.state = kUIStatePhoneVerification;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _state = kUIStateNone;
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *descriptionLabel = self.descriptionLabel;
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:descriptionLabel];
    
    UIView *startButton = self.startButton;
    startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:startButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(descriptionLabel, startButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[startButton]-20-[descriptionLabel]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[descriptionLabel]-15-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[startButton]-15-|" options:0 metrics:nil views:views]];
    
}

- (void)logOutWithCompletion:(void (^)(BOOL success))completion {
    [[Digits sharedInstance] logOut];
    [RJParseUser logOutInBackgroundWithBlock:^(NSError *error) {
        if (completion) {
            completion(!error);
        }
    }];
}

- (void)startWithPresentingViewController:(UIViewController *)viewController completion:(void (^)(RJParseUser *))completion {
    self.state = kUIStateNone;
    
    self.completion = completion;
    self.viewControllerForPresentation = viewController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    [self.viewControllerForPresentation presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    self.navigationItem.title = [NSLocalizedString(@"Login to Classy", nil) uppercaseString];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem cancelBarButtonItemWithTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:styleManager.accentColor];
    
    self.view.backgroundColor = styleManager.themeColor;
    
    self.descriptionLabel.text = NSLocalizedString(@"Users can compete with friends, write comments, like playlists, buy premium playlists, and earn exclusive rewards, all to get that 365-Beach-Body!", nil);
    self.descriptionLabel.textColor = styleManager.windowTintColor;
    self.descriptionLabel.font = styleManager.mediumFont;
    
    self.startButton.titleLabel.font = styleManager.mediumFont;
    [self.startButton setTitleColor:styleManager.tintBlueColor forState:UIControlStateNormal];
    [self.startButton setTitleColor:styleManager.windowTintColor forState:UIControlStateHighlighted];

    NSString *startButtonTitle = NSLocalizedString(@"Login Now", nil);
    NSMutableDictionary *normalAttributes =
    [[NSMutableDictionary alloc] initWithDictionary:
     [RJStyleManager attributesWithFont:styleManager.mediumFont textColor:styleManager.tintBlueColor textAlignment:NSTextAlignmentCenter]];
    [normalAttributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    [self.startButton setAttributedTitle:[[NSAttributedString alloc] initWithString:startButtonTitle attributes:normalAttributes] forState:UIControlStateNormal];
    
    NSMutableDictionary *highlightAttributes =
    [[NSMutableDictionary alloc] initWithDictionary:
     [RJStyleManager attributesWithFont:styleManager.mediumFont textColor:styleManager.lightTextColor textAlignment:NSTextAlignmentCenter]];
    [highlightAttributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    [self.startButton setAttributedTitle:[[NSAttributedString alloc] initWithString:startButtonTitle attributes:highlightAttributes] forState:UIControlStateHighlighted];
    
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static RJAuthenticationViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RJAuthenticationViewController alloc] initWithNibName:nil bundle:nil];
    });
    return sharedInstance;
}

@end
