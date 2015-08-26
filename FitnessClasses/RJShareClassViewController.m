//
//  RJShareClassViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 8/22/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJMixpanelConstants.h"
#import "RJParseClass.h"
#import "RJShareClassViewController.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"
#import <Mixpanel/Mixpanel.h>
@import MessageUI.MFMessageComposeViewController;
@import Social;


@interface RJShareClassViewController () <MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong, readonly) UIButton *facebookButton;
@property (nonatomic, strong, readonly) UIButton *messagesButton;
@property (nonatomic, strong, readonly) UIButton *twitterButton;

@end


@implementation RJShareClassViewController

#pragma mark - Private Protocols - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    if (result == MessageComposeResultSent) {
        [[Mixpanel sharedInstance] track:kRJMixpanelConstantsSharedViaMessages properties:[self propertiesForAnalyticsEvent]];
    }
}

#pragma mark - Private Instance Methods

- (NSDictionary *)propertiesForAnalyticsEvent {
    return @{
             kRJMixpanelConstantsPlayedClassClassNameDictionaryKey : self.klass.name,
             kRJMixpanelConstantsPlayedClassClassObjectIDDictionaryKey : self.klass.objectId
             };
}

- (NSString *)textForShares {
    if (self.klass) {
        return [NSString stringWithFormat:@"I just crushed the %@ workout on Classy! http://ios.getclassy.co", self.klass.name];
    } else {
        return nil;
    }
}

- (void)updateButtonUI:(UIButton *)button withTitle:(NSString *)title color:(UIColor *)color imageName:(NSString *)imageName {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    [button setImage:[UIImage tintableImageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage tintableImageNamed:imageName] forState:UIControlStateHighlighted];
    button.imageView.tintColor = color;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setBackgroundImage:[UIImage imageWithColor:[color colorWithAlphaComponent:0.7f]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
    [button.imageView setTintColor:[UIColor whiteColor]];
    button.titleLabel.numberOfLines = 2;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSMutableAttributedString *buttonText = [[NSMutableAttributedString alloc] init];
    NSDictionary *titleAttributes = @{
                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                      NSFontAttributeName : styleManager.verySmallBoldFont,
                                      NSParagraphStyleAttributeName : paragraphStyle
                                      };
    [buttonText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:titleAttributes]];
    [button setAttributedTitle:buttonText forState:UIControlStateNormal];
}

#pragma mark - Private Instance Methods - Handlers

- (void)facebookButtonPressed:(UIButton *)button {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] && self.klass) {
        [[Mixpanel sharedInstance] track:kRJMixpanelConstantsClickedFacebookShareButton properties:[self propertiesForAnalyticsEvent]];
        
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:[self textForShares]];
        [self presentViewController:composeViewController animated:YES completion:nil];
        
        __weak SLComposeViewController *weakComposeViewController = composeViewController;
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            [[weakComposeViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            if (result == SLComposeViewControllerResultDone) {
                [[Mixpanel sharedInstance] track:kRJMixpanelConstantsSharedViaFacebook properties:[self propertiesForAnalyticsEvent]];
            }
        }];
    }
}

- (void)twitterButtonPressed:(UIButton *)button {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && self.klass) {
        [[Mixpanel sharedInstance] track:kRJMixpanelConstantsClickedTwitterShareButton properties:[self propertiesForAnalyticsEvent]];
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:[self textForShares]];
        [self presentViewController:composeViewController animated:YES completion:nil];
        
        __weak SLComposeViewController *weakComposeViewController = composeViewController;
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            [[weakComposeViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            if (result == SLComposeViewControllerResultDone) {
                [[Mixpanel sharedInstance] track:kRJMixpanelConstantsSharedViaTwitter properties:[self propertiesForAnalyticsEvent]];
            }
        }];
    }
}

- (void)messagesButtonPressed:(UIButton *)button {
    if ([MFMessageComposeViewController canSendText] && self.klass) {
        [[Mixpanel sharedInstance] track:kRJMixpanelConstantsClickedMessagesShareButton properties:[self propertiesForAnalyticsEvent]];
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
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *messagesButton = self.messagesButton;
    messagesButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:messagesButton];
    UIView *facebookButton = self.facebookButton;
    facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:facebookButton];
    UIView *twitterButton = self.twitterButton;
    twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:twitterButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(messagesButton, facebookButton, twitterButton);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[facebookButton]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[messagesButton]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[twitterButton]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[twitterButton][facebookButton(==twitterButton)][messagesButton(==twitterButton)]|" options:0 metrics:nil views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    [self.facebookButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.twitterButton addTarget:self action:@selector(twitterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.messagesButton addTarget:self action:@selector(messagesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *facebookColor = [UIColor colorWithRed:59.0f/255.0f green:89.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
    [self updateButtonUI:self.facebookButton withTitle:NSLocalizedString(@"Facebook", nil) color:facebookColor imageName:@"facebookIcon"];
    self.facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 0.0f);
    self.facebookButton.imageEdgeInsets = UIEdgeInsetsMake(12.0f, 4.0f, 12.0f, 0.0f);
    self.facebookButton.titleLabel.font = styleManager.verySmallBoldFont;
    
    UIColor *twitterColor = [UIColor colorWithRed:19.0f/255.0f green:154.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
    [self updateButtonUI:self.twitterButton withTitle:NSLocalizedString(@"Twitter", nil) color:twitterColor imageName:@"twitterIcon"];
    self.twitterButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -11.0f, 0.0f, 0.0f);
    self.twitterButton.imageEdgeInsets = UIEdgeInsetsMake(12.0f, -6.0f, 12.0f, 0.0f);
    self.twitterButton.titleLabel.font = styleManager.verySmallBoldFont;
    
    UIColor *messagesColor = [UIColor colorWithRed:0.0f/255.0f green:163.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self updateButtonUI:self.messagesButton withTitle:NSLocalizedString(@"Message", nil) color:messagesColor imageName:@"messagesIcon"];
    self.messagesButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -4.0f, 0.0f, 0.0f);
    self.messagesButton.imageEdgeInsets = UIEdgeInsetsMake(12.0f, -2.0f, 12.0f, 0.0f);
    self.messagesButton.titleLabel.font = styleManager.verySmallBoldFont;
}

@end