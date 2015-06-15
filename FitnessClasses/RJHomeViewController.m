//
//  RJHomeViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/2/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAuthenticationViewController.h"
#import "RJHomeGalleryViewController.h"
#import "RJHomeTitleView.h"
#import "RJHomeViewController.h"
#import "RJParseClass.h"
#import "RJParseUser.h"
#import "RJSettingsViewController.h"
#import "RJSortOptionsViewController.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"
#import <SVProgressHUD/SVProgressHUD.h>


@interface RJHomeViewController () <RJHomeGalleryViewControllerDelegate, RJSortOptionsViewControllerDelegate>

@property (nonatomic, strong, readonly) RJHomeGalleryViewController *galleryViewController;
@property (nonatomic, strong, readonly) RJSortOptionsViewController *sortOptionsViewController;

@end


@implementation RJHomeViewController

@synthesize galleryViewController = _galleryViewController;
@synthesize sortOptionsViewController = _sortOptionsViewController;

#pragma mark - Public Properties

- (RJHomeGalleryViewController *)galleryViewController {
    if (!_galleryViewController) {
        _galleryViewController = [[RJHomeGalleryViewController alloc] init];
        _galleryViewController.homeGalleryDelegate = self;
    }
    return _galleryViewController;
}

- (RJSortOptionsViewController *)sortOptionsViewController {
    if (!_sortOptionsViewController) {
        _sortOptionsViewController = [[RJSortOptionsViewController alloc] initWithScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _sortOptionsViewController.sortOptionsDelegate = self;
    }
    return _sortOptionsViewController;
}

#pragma mark - Private Protocols - RJHomeGalleryViewControllerDelegate

- (void)homeGalleryViewController:(RJHomeGalleryViewController *)homeGalleryViewController wantsPlayForClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay {
    [self.delegate homeViewController:self wantsPlayForClass:klass autoPlay:autoPlay];
}

#pragma mark - Private Protocols - RJSortOptionsViewControllerDelegate

- (void)sortOptionsViewControllerDidSelectNew:(RJSortOptionsViewController *)sortOptionsViewController {
    [SVProgressHUD show];
    [self.galleryViewController switchToNewClassesWithCompletion:^{
        [SVProgressHUD dismiss];
    }];
}

- (void)sortOptionsViewControllerDidSelectPopular:(RJSortOptionsViewController *)sortOptionsViewController {
    [SVProgressHUD show];
    [self.galleryViewController switchToPopularClassesWithCompletion:^{
        [SVProgressHUD dismiss];
    }];
}

- (void)sortOptionsViewController:(RJSortOptionsViewController *)sortOptionsViewController didSelectCategory:(RJParseCategory *)category {
    [SVProgressHUD show];
    [self.galleryViewController switchToClassesForCategory:category completion:^{
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - Private Instance Methods

- (void)settingsButtonPressed:(UIBarButtonItem *)settingsButton {
    if ([RJParseUser currentUser]) {
        RJSettingsViewController *settingsViewController = [[RJSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [[self navigationController] pushViewController:settingsViewController animated:YES];
    } else {
        [[RJAuthenticationViewController sharedInstance] startWithPresentingViewController:self completion:^(RJParseUser *user) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)titleViewTapRecognized:(UITapGestureRecognizer *)tapRecognized {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSUInteger centers = (NSUInteger)CGRectGetWidth(window.bounds);
    NSUInteger randomCenter = arc4random_uniform((uint32_t)centers);
    
    CGFloat sideLength = 80.0f;
    CGFloat originX = (randomCenter-sideLength/2);
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.frame = CGRectMake(originX, -sideLength, sideLength, sideLength);
    [window addSubview:logo];
    
    [UIView animateWithDuration:1.2
                     animations:^{
                         logo.frame = CGRectMake(originX, CGRectGetHeight(window.bounds), sideLength, sideLength);
                     }
                     completion:^(BOOL finished) {
                         [logo removeFromSuperview];
                     }];
}

#pragma mark - Public Instance Methods

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *galleryView = self.galleryViewController.view;
    galleryView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *sortOptionsView = self.sortOptionsViewController.view;
    sortOptionsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:galleryView];
    [self.view addSubview:sortOptionsView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(galleryView, sortOptionsView);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[galleryView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sortOptionsView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sortOptionsView(40)][galleryView]|" options:0 metrics:nil views:views]];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [self.galleryViewController reloadWithCompletion:completion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJHomeTitleView *titleView = [[RJHomeTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 44.0f)];
    [titleView.settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewTapRecognized:)];
    [titleView.titleView addGestureRecognizer:tapRecognizer];
    self.navigationItem.titleView = titleView;
    
    [self.galleryViewController willMoveToParentViewController:self];
    [self.sortOptionsViewController willMoveToParentViewController:self];
    
    [self addChildViewController:self.galleryViewController];
    [self addChildViewController:self.sortOptionsViewController];
    
    [self.galleryViewController didMoveToParentViewController:self];
    [self.sortOptionsViewController didMoveToParentViewController:self];
    
    [self.galleryViewController switchToNewClassesWithCompletion:^{
        NSArray *classes = self.galleryViewController.classes;
        if (classes) {
            NSUInteger firstFreeClassIndex = [classes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return ([[(RJParseClass *)obj creditsCost] unsignedIntegerValue] == 0);
            }];
            
            if (firstFreeClassIndex != NSNotFound) {
                [self.delegate homeViewController:self wantsPlayForClass:classes[firstFreeClassIndex] autoPlay:NO];
            }
        }
    }];
}

@end
