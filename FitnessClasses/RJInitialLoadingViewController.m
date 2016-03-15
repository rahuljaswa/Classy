//
//  RJInitialLoadingViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 10/24/15.
//
//

#import "RJInitialLoadingViewController.h"
#import "RJParseTemplate.h"
#import "RJParseUser.h"
#import "RJStyleManager.h"
#import <UIToolkitIOS/RJInsetLabel.h>
#import <UIToolkitIOS/UIImage+RJAdditions.h>

typedef NS_ENUM(NSInteger, FetchStatus) {
    kFetchStatusBegan,
    kFetchStatusSucceeded,
    kFetchStatusFailed
};


@interface RJInitialLoadingViewController ()

@property (nonatomic, assign) FetchStatus currentTemplateFetchStatus;
@property (nonatomic, assign) FetchStatus currentUserFetchStatus;

@property (nonatomic, strong, readonly) RJInsetLabel *textLabel;
@property (nonatomic, strong, readonly) UIButton *retryButton;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinner;

@end


@implementation RJInitialLoadingViewController

#pragma mark - Private Instance Methods

- (void)fetchCurrentTemplateWithCompletion:(void (^)(RJParseTemplate *currentTemplate, BOOL fetchSuccess))completion {
    [RJParseTemplate loadCurrentTemplateWithCompletion:^(RJParseTemplate *currentTemplate, BOOL fetchSuccess) {
        if (completion) {
            completion(currentTemplate, fetchSuccess);
        }
    }];
}

- (void)fetchCurrentUserWithCompletion:(void (^)(RJParseUser *currentUser, BOOL fetchSuccess))completion {
    [RJParseUser loadCurrentUserWithSubscriptionsWithCompletion:^(RJParseUser *currentUser, BOOL fetchSuccess) {
        if (completion) {
            completion(currentUser, fetchSuccess);
        }
    }];
}

- (void)fetchCurrentUserAndCurrentTemplate {
    if ([RJParseTemplate currentTemplate]) {
        self.currentTemplateFetchStatus = kFetchStatusSucceeded;
        [self finishIfPossible];
    } else {
        self.currentTemplateFetchStatus = kFetchStatusBegan;
        [self fetchCurrentTemplateWithCompletion:^(RJParseTemplate *currentTemplate, BOOL fetchSuccess) {
            if (fetchSuccess) {
                self.currentTemplateFetchStatus = kFetchStatusSucceeded;
            } else {
                self.currentTemplateFetchStatus = kFetchStatusFailed;
            }
            [self finishIfPossible];
        }];
    }
    
    if ([RJParseUser currentUserWithSubscriptions]) {
        self.currentUserFetchStatus = kFetchStatusSucceeded;
        [self finishIfPossible];
    } else {
        self.currentUserFetchStatus = kFetchStatusBegan;
        [self fetchCurrentUserWithCompletion:^(RJParseUser *currentUser, BOOL fetchSuccess) {
            if (fetchSuccess) {
                self.currentUserFetchStatus = kFetchStatusSucceeded;
            } else {
                self.currentUserFetchStatus = kFetchStatusFailed;
            }
            [self finishIfPossible];
        }];
    }
}

- (void)finishIfPossible {
    if ((self.currentTemplateFetchStatus == kFetchStatusSucceeded) &&
        (self.currentUserFetchStatus == kFetchStatusSucceeded) &&
        [self.delegate respondsToSelector:@selector(initialLoadingViewControllerDidFinish:)])
    {
        [self.delegate initialLoadingViewControllerDidFinish:self];
    } else if ((self.currentTemplateFetchStatus == kFetchStatusFailed) ||
               (self.currentUserFetchStatus == kFetchStatusFailed))
    {
        [self.retryButton setTitle:NSLocalizedString(@"Retry", nil) forState:UIControlStateNormal];
        self.retryButton.userInteractionEnabled = YES;
    }
}

- (void)retryButtonPressed:(UIButton *)retryButton {
    [self fetchCurrentUserAndCurrentTemplate];
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _textLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *spinner = self.spinner;
    spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:spinner];
    
    UIView *retryButton = self.retryButton;
    retryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:retryButton];
    
    UIView *textLabel = self.textLabel;
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:textLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(spinner, textLabel, retryButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[spinner]-40-[textLabel]-40-[retryButton(>=40)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[textLabel]-30-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spinner]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[retryButton(>=100)]" options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:retryButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    self.view.backgroundColor = styleManager.defaultAccentColor;
    
    [self.retryButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.0f alpha:0.7f]] forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.retryButton setTitleColor:styleManager.defaultAccentColor forState:UIControlStateNormal];
    self.retryButton.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    self.retryButton.clipsToBounds = YES;
    self.retryButton.layer.cornerRadius = 5.0f;
    self.retryButton.titleLabel.numberOfLines = 0;
    [self.retryButton setTitle:NSLocalizedString(@"Updating...", nil) forState:UIControlStateNormal];
    self.retryButton.userInteractionEnabled = NO;
    self.retryButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
    
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30.0f];
    self.textLabel.text = NSLocalizedString(@"This should only take a moment!", nil);
    
    [self.spinner startAnimating];
    
    [self fetchCurrentUserAndCurrentTemplate];
}

@end
