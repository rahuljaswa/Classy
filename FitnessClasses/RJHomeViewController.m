//
//  RJHomeViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/2/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAssetImageCacheEntity.h"
#import "RJAuthenticationViewController.h"
#import "RJHomeGalleryViewController.h"
#import "RJHomeTitleView.h"
#import "RJHomeViewController.h"
#import "RJParseClass.h"
#import "RJParseTemplate.h"
#import "RJParseUser.h"
#import "RJSettingsViewController.h"
#import "RJSortOptionsViewController.h"
#import "RJStyleManager.h"
#import "UIImageView+FastImageCache.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <UIToolkitIOS/UIImage+RJAdditions.h>


@interface RJHomeViewController () <RJHomeGalleryViewControllerDelegate, RJSortOptionsViewControllerDelegate>

@property (nonatomic, strong, readonly) RJHomeGalleryViewController *galleryViewController;
@property (nonatomic, strong, readonly) RJSortOptionsViewController *sortOptionsViewController;
@property (nonatomic, strong, readonly) UIView *spacer;
@property (nonatomic, strong, readonly) RJHomeTitleView *titleView;

@end


@implementation RJHomeViewController

@synthesize galleryViewController = _galleryViewController;
@synthesize sortOptionsViewController = _sortOptionsViewController;
@synthesize spacer = _spacer;

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
        _sortOptionsViewController = [[RJSortOptionsViewController alloc] init];
        _sortOptionsViewController.sortOptionsDelegate = self;
    }
    return _sortOptionsViewController;
}

- (UIView *)spacer {
    if (!_spacer) {
        _spacer = [[UIView alloc] initWithFrame:CGRectZero];
        _spacer.backgroundColor = [RJStyleManager sharedInstance].themeTextColor;
    }
    return _spacer;
}

#pragma mark - Private Protocols - RJHomeGalleryViewControllerDelegate

- (void)homeGalleryViewController:(RJHomeGalleryViewController *)homeGalleryViewController wantsPlayForClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay {
    [self.delegate homeViewController:self wantsPlayForClass:klass autoPlay:autoPlay];
}

#pragma mark - Private Protocols - RJSortOptionsViewControllerDelegate

- (void)sortOptionsViewController:(RJSortOptionsViewController *)sortOptionsViewController didSelectCategory:(RJParseCategory *)category {
    [self.titleView.spinner startAnimating];
    [self.galleryViewController switchToClassesForCategory:category completion:^{
        self.galleryViewController.collectionView.contentOffset = CGPointZero;
        [self.titleView.spinner stopAnimating];
    }];
}

#pragma mark - Private Instance Methods

- (void)settingsButtonPressed:(UIBarButtonItem *)settingsButton {
    if ([RJParseUser currentUserWithSubscriptions]) {
        RJSettingsViewController *settingsViewController = [[RJSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [[self navigationController] pushViewController:settingsViewController animated:YES];
    } else {
        [[RJAuthenticationViewController sharedInstance] startWithPresentingViewController:self completion:^(RJParseUser *user) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)titleViewTapRecognized:(UITapGestureRecognizer *)tapRecognized {
    RJParseTemplate *template = [RJParseTemplate currentTemplate];
    if (template.appIconImageURL) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        NSUInteger centers = (NSUInteger)CGRectGetWidth(window.bounds);
        NSUInteger randomCenter = arc4random_uniform((uint32_t)centers);
        
        CGFloat sideLength = 80.0f;
        CGFloat originX = (randomCenter-sideLength/2);
        
        UIImageView *logo = [[UIImageView alloc] init];
        RJAssetImageCacheEntity *entity = [[RJAssetImageCacheEntity alloc] initWithAssetImageURL:[NSURL URLWithString:template.appIconImageURL]];
        [logo setImageEntity:entity formatName:kRJAssetImageFormatAppIcon placeholder:nil];
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
}

#pragma mark - Public Instance Methods

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *galleryView = self.galleryViewController.view;
    galleryView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *sortOptionsView = self.sortOptionsViewController.view;
    sortOptionsView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *spacer = self.spacer;
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:galleryView];
    [self.view addSubview:sortOptionsView];
    [self.view addSubview:spacer];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(galleryView, sortOptionsView, spacer);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[galleryView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spacer]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sortOptionsView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sortOptionsView(50)][spacer(1)][galleryView]|" options:0 metrics:nil views:views]];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    [self.galleryViewController reloadWithCompletion:completion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleView = [[RJHomeTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 44.0f)];
    [_titleView.settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewTapRecognized:)];
    [_titleView.titleView addGestureRecognizer:tapRecognizer];
    self.navigationItem.titleView = _titleView;
    
    [self.galleryViewController willMoveToParentViewController:self];
    [self.sortOptionsViewController willMoveToParentViewController:self];
    
    [self addChildViewController:self.galleryViewController];
    [self addChildViewController:self.sortOptionsViewController];
    
    [self.galleryViewController didMoveToParentViewController:self];
    [self.sortOptionsViewController didMoveToParentViewController:self];
}

@end
