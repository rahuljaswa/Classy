//
//  RJClassDetailsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJClassCommentsViewController.h"
#import "RJClassDetailsViewController.h"
#import "RJCreateEditChoreographedClassViewController.h"
#import "RJCreateEditSelfPacedClassViewController.h"
#import "RJParseCategory.h"
#import "RJParseClass.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJStackedTitleView.h"
#import "RJStyleManager.h"
#import "UIBarButtonItem+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <ChatViewControllers/RJWriteChatView.h>
@import MessageUI.MFMessageComposeViewController;
@import Social;


@interface RJClassDetailsViewController () <MFMessageComposeViewControllerDelegate, RJClassCommentsViewControllerDelegate>

@property (nonatomic, strong, readonly) UIButton *facebookButton;
@property (nonatomic, strong, readonly) UIButton *messagesButton;
@property (nonatomic, strong, readonly) UIButton *twitterButton;

@property (nonatomic, strong, readonly) RJStackedTitleView *titleView;

@property (nonatomic, strong, readonly) RJClassCommentsViewController *commentsViewController;

@end


@implementation RJClassDetailsViewController

@synthesize commentsViewController = _commentsViewController;

#pragma mark - Public Properties

- (void)setKlass:(RJParseClass *)klass {
    _klass = klass;
    [self updateUI];
}

- (void)setShowsPlayButton:(BOOL)showsPlayButton {
    _showsPlayButton = showsPlayButton;
    if (_showsPlayButton) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem playBarButtonItemWithTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:[RJStyleManager sharedInstance].accentColor];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Private Properties

- (RJClassCommentsViewController *)commentsViewController {
    if (!_commentsViewController) {
        _commentsViewController = [[RJClassCommentsViewController alloc] initWithStyle:UITableViewStylePlain];
        _commentsViewController.classCommentsDelegate = self;
    }
    return _commentsViewController;
}

#pragma mark - Private Protocols - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [[controller  presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Protocols - RJClassCommentsViewControllerDelegate

- (void)classCommentsViewControllerDidPressSendButton:(RJClassCommentsViewController *)classCommentsViewController {
    NSString *text = classCommentsViewController.writeChatView.commentView.text;
    if ([text length] > 0) {
        [classCommentsViewController.writeChatView reset];
        [RJParseUtils insertCommentForClass:self.klass text:text completion:^(BOOL success) {
            if (success) {
                [RJParseUtils fetchClassWithId:self.klass.objectId completion:^(RJParseClass *klass) {
                    if (klass) {
                        self.klass = klass;
                    }
                }];
            }
        }];
    }
}

#pragma mark - Private Instance Methods

- (void)playButtonPressed:(UIButton *)button {
    [self.delegate classDetailsViewControllerDidPressPlayButton:self];
}

- (NSString *)textForShares {
    return [NSString stringWithFormat:@"I just crushed the %@ workout on Classy! http://ios.getclassy.co", self.klass.name];
}

- (void)updateButtonUI:(UIButton *)button withTitle:(NSString *)title color:(UIColor *)color imageName:(NSString *)imageName {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    [button setImage:[UIImage tintableImageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage tintableImageNamed:imageName] forState:UIControlStateHighlighted];
    button.titleLabel.font = styleManager.mediumBoldFont;
    button.imageView.tintColor = color;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[color colorWithAlphaComponent:0.7f]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.imageView setTintColor:[UIColor whiteColor]];
}

- (void)updateUI {
    self.titleView.textLabel.text = [self.klass.name uppercaseString];
    self.titleView.detailTextLabel.text = self.klass.category.name;
    [self.commentsViewController setComments:self.klass.comments likes:self.klass.likes];
}

#pragma mark - Private Instance Methods - Handlers

- (void)editButtonPressed:(UIButton *)button {
    RJParseClassType classType = [self.klass.classType integerValue];
    switch (classType) {
        case kRJParseClassTypeNone:
            break;
        case kRJParseClassTypeChoreographed: {
            RJCreateEditChoreographedClassViewController *editViewController = [[RJCreateEditChoreographedClassViewController alloc] init];
            editViewController.klass = self.klass;
            [[self navigationController] pushViewController:editViewController animated:YES];
            break;
        }
        case kRJParseClassTypeSelfPaced: {
            RJCreateEditSelfPacedClassViewController *editViewController = [[RJCreateEditSelfPacedClassViewController alloc] init];
            editViewController.klass = self.klass;
            [[self navigationController] pushViewController:editViewController animated:YES];
            break;
        }
    }
}

- (void)facebookButtonPressed:(UIButton *)button {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:[self textForShares]];
        [self presentViewController:composeViewController animated:YES completion:nil];
        
        __weak SLComposeViewController *weakComposeViewController = composeViewController;
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            [[weakComposeViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)twitterButtonPressed:(UIButton *)button {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:[self textForShares]];
        [self presentViewController:composeViewController animated:YES completion:nil];
        
        __weak SLComposeViewController *weakComposeViewController = composeViewController;
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            [[weakComposeViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)messagesButtonPressed:(UIButton *)button {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
        messageViewController.messageComposeDelegate = self;
        messageViewController.body = [self textForShares];
        [self presentViewController:messageViewController animated:YES completion:nil];
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _messagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleView = [[RJStackedTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *commentsView = self.commentsViewController.view;
    commentsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.commentsViewController willMoveToParentViewController:self];
    [self addChildViewController:self.commentsViewController];
    [self.view addSubview:commentsView];
    [self.commentsViewController didMoveToParentViewController:self];
    
    UIView *messagesButton = self.messagesButton;
    messagesButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:messagesButton];
    UIView *facebookButton = self.facebookButton;
    facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:facebookButton];
    UIView *twitterButton = self.twitterButton;
    twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:twitterButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(commentsView, messagesButton, facebookButton, twitterButton);
    NSDictionary *metrics = @{
                              @"buttonHeight" : @(40.0f),
                              @"verticalSpacing" : @(20.0f),
                              @"horizontalSpacing" : @(20.0f)
                              };
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalSpacing-[facebookButton(buttonHeight)]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalSpacing-[twitterButton(buttonHeight)]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalSpacing-[messagesButton(buttonHeight)]-verticalSpacing-[commentsView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalSpacing-[twitterButton][facebookButton][messagesButton]-horizontalSpacing-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[twitterButton][facebookButton(==twitterButton)][messagesButton(==twitterButton)]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[commentsView]|" options:0 metrics:metrics views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    
    self.navigationItem.titleView = self.titleView;
    if ([[RJParseUser currentUser] admin]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage tintableImageNamed:@"settingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:item];
    }
    
    [self.facebookButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.twitterButton addTarget:self action:@selector(twitterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.messagesButton addTarget:self action:@selector(messagesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    self.titleView.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.detailTextLabel.textColor = styleManager.themeTextColor;
    self.titleView.detailTextLabel.font = styleManager.verySmallBoldFont;
    
    self.titleView.textLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.textLabel.textColor = styleManager.titleColor;
    self.titleView.textLabel.font = styleManager.navigationBarFont;
    
    self.commentsViewController.view.backgroundColor = [UIColor clearColor];
    self.commentsViewController.writeChatView.backgroundColor = styleManager.themeBackgroundColor;
    self.commentsViewController.writeChatView.commentView.backgroundColor = [UIColor clearColor];
    self.commentsViewController.writeChatView.commentView.textColor = styleManager.themeTextColor;
    self.commentsViewController.writeChatView.commentView.tintColor = styleManager.themeTextColor;
    self.commentsViewController.writeChatView.commentView.layer.borderColor = styleManager.themeTextColor.CGColor;
    self.commentsViewController.writeChatView.commentView.layer.borderWidth = 1.0f;
    [self.commentsViewController.writeChatView.sendButton setTitleColor:styleManager.themeTextColor forState:UIControlStateNormal];
    self.commentsViewController.writeChatView.sendButton.titleLabel.font = styleManager.verySmallBoldFont;
    
    UIColor *facebookColor = [UIColor colorWithRed:59.0f/255.0f green:89.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
    [self updateButtonUI:self.facebookButton withTitle:NSLocalizedString(@"Facebook", nil) color:facebookColor imageName:@"facebookIcon"];
    self.facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    self.facebookButton.imageEdgeInsets = UIEdgeInsetsMake(12.0f, 5.0f, 12.0f, 0.0f);
    self.facebookButton.titleLabel.font = styleManager.verySmallBoldFont;
    
    UIColor *twitterColor = [UIColor colorWithRed:19.0f/255.0f green:154.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
    [self updateButtonUI:self.twitterButton withTitle:NSLocalizedString(@"Twitter", nil) color:twitterColor imageName:@"twitterIcon"];
    self.twitterButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -5.0f, 0.0f, 0.0f);
    self.twitterButton.imageEdgeInsets = UIEdgeInsetsMake(12.0f, 0.0f, 12.0f, 0.0f);
    self.twitterButton.titleLabel.font = styleManager.verySmallBoldFont;
    
    UIColor *messagesColor = [UIColor colorWithRed:0.0f/255.0f green:163.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self updateButtonUI:self.messagesButton withTitle:NSLocalizedString(@"Message", nil) color:messagesColor imageName:@"messagesIcon"];
    self.messagesButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.messagesButton.imageEdgeInsets = UIEdgeInsetsMake(12.0f, 0.0f, 12.0f, 0.0f);
    self.messagesButton.titleLabel.font = styleManager.verySmallBoldFont;
}

@end
