//
//  RJPlayingClassViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJChoreographedPlayingClassViewController.h"
#import "RJClassDetailsViewController.h"
#import "RJClassSummaryView.h"
#import "RJParseClass.h"
#import "RJPlayingClassViewController.h"
#import "RJSoundCloudTrack.h"
#import "RJStackedTitleView.h"
#import "RJCreditsHelper.h"
#import "RJSelfPacedPlayingClassViewController.h"
#import "RJStyleManager.h"
#import "RJTrackImageCacheEntity.h"
#import "UIBarButtonItem+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import "UIImageView+FastImageCache.h"


@interface RJPlayingClassViewController () <RJChoreographedPlayingClassViewControllerDelegate>

@property (nonatomic, strong, readwrite) RJParseClass *klass;

@property (nonatomic, strong, readonly) RJClassSummaryView *summaryView;
@property (nonatomic, strong, readonly) RJStackedTitleView *titleView;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UIViewController *currentPlayingClassViewController;

@end


@implementation RJPlayingClassViewController

@synthesize classStarted;

#pragma mark - Public Properties

- (BOOL)hasClassStarted {
    if (self.currentPlayingClassViewController) {
        if ([self.currentPlayingClassViewController isKindOfClass:[RJChoreographedPlayingClassViewController class]]) {
            RJChoreographedPlayingClassViewController *choreographedClassViewController = (RJChoreographedPlayingClassViewController *)self.currentPlayingClassViewController;
            return choreographedClassViewController.hasClassStarted;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)setKlass:(RJParseClass *)klass {
    [self setKlass:klass withAutoPlay:NO];
}

- (void)setKlass:(RJParseClass *)klass withAutoPlay:(BOOL)autoPlay {
    RJParseClass *previousClass = _klass;
    _klass = klass;
    
    if (self.currentPlayingClassViewController) {
        if (previousClass.formattedClassType == _klass.formattedClassType) {
            if ([self.currentPlayingClassViewController isKindOfClass:[RJChoreographedPlayingClassViewController class]]) {
                RJChoreographedPlayingClassViewController *choreographedClassViewController = (RJChoreographedPlayingClassViewController *)self.currentPlayingClassViewController;
                [choreographedClassViewController setKlass:_klass withAutoPlay:autoPlay];
            } else {
                RJSelfPacedPlayingClassViewController *selfPacedClassViewController = (RJSelfPacedPlayingClassViewController *)self.currentPlayingClassViewController;
                selfPacedClassViewController.klass = _klass;
            }
        } else {
            UIViewController *oldViewController = self.currentPlayingClassViewController;
            self.currentPlayingClassViewController = [self setupViewControllerForClass:_klass autoPlay:autoPlay];
            [oldViewController willMoveToParentViewController:nil];
            [self addChildViewController:self.currentPlayingClassViewController];
            
            [self transitionFromViewController:oldViewController
                              toViewController:self.currentPlayingClassViewController
                                      duration:0.0
                                       options:UIViewAnimationOptionTransitionNone
                                    animations:^{
                                        [self setupConstraintsForNewCurrentPlayingClassViewController:self.currentPlayingClassViewController];
                                    }
                                    completion:^(BOOL finished) {
                                        [oldViewController removeFromParentViewController];
                                        [self.currentPlayingClassViewController didMoveToParentViewController:self];
                                    }];
        }
    } else {
        self.currentPlayingClassViewController = [self setupViewControllerForClass:_klass autoPlay:autoPlay];
        [self.currentPlayingClassViewController willMoveToParentViewController:self];
        [self addChildViewController:self.currentPlayingClassViewController];
        [self.view addSubview:self.currentPlayingClassViewController.view];
        [self setupConstraintsForNewCurrentPlayingClassViewController:self.currentPlayingClassViewController];
        [self.currentPlayingClassViewController didMoveToParentViewController:self];
    }
    
    self.summaryView.classTitle.text = [_klass.name uppercaseString];
    self.summaryView.track.text = nil;
    self.titleView.textLabel.text = [_klass.name uppercaseString];
    self.titleView.detailTextLabel.text = nil;
}

- (void)setMinimized:(BOOL)minimized {
    _minimized = minimized;
    [[self navigationController] setNavigationBarHidden:_minimized animated:(self.isViewLoaded && self.view.window)];
    if (_minimized) {
        [self.view addGestureRecognizer:self.tapRecognizer];
    } else {
        [self.view removeGestureRecognizer:self.tapRecognizer];
    }
}

#pragma mark - Private Protocols - RJChoreographedPlayingClassViewControllerDelegate

- (void)choreographedPlayingClassViewControllerPlaybackTimeDidChange:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController {
    NSUInteger totalTime = [choreographedPlayingClassViewController.klass.length unsignedIntegerValue];
    self.titleView.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString hhmmaaForTotalSeconds:choreographedPlayingClassViewController.playbackTime], [NSString hhmmaaForTotalSeconds:totalTime]];
}

- (void)choreographedPlayingClassViewControllerTrackDidChange:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController {
    self.summaryView.track.text = choreographedPlayingClassViewController.currentTrack.title;
    if (choreographedPlayingClassViewController.currentTrack) {
        NSURL *url = [NSURL URLWithString:choreographedPlayingClassViewController.currentTrack.artworkURL];
        RJTrackImageCacheEntity *trackEntity = [[RJTrackImageCacheEntity alloc] initWithTrackImageURL:url objectID:choreographedPlayingClassViewController.currentTrack.trackID];
        [self.summaryView.trackArtwork setImageEntity:trackEntity formatName:kRJTrackImageFormatCardSquare16BitBGR placeholder:nil];
    } else {
        self.summaryView.trackArtwork.image = nil;
    }
}

- (void)choreographedPlayingClassViewControllerReadyToPlayPendingClass:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController {
    [self.summaryView.playPauseButton setImage:[UIImage tintableImageNamed:@"circledPlayIcon"] forState:UIControlStateNormal];
}

- (void)choreographedPlayingClassViewControllerWillPause:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController {
    [self.summaryView.playPauseButton setImage:[UIImage tintableImageNamed:@"circledPlayIcon"] forState:UIControlStateNormal];
}

- (void)choreographedPlayingClassViewControllerWillPlay:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController {
    [self.summaryView.playPauseButton setImage:[UIImage tintableImageNamed:@"pauseIcon"] forState:UIControlStateNormal];
}

#pragma mark - Private Instance Methods

- (void)setupConstraintsForNewCurrentPlayingClassViewController:(UIViewController *)viewController {
    UIView *summaryView = self.summaryView;
    
    UIView *currentPlayingClassViewControllerView = viewController.view;
    currentPlayingClassViewControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(currentPlayingClassViewControllerView, summaryView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[summaryView][currentPlayingClassViewControllerView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[currentPlayingClassViewControllerView]|" options:0 metrics:nil views:views]];
}

- (UIViewController *)setupViewControllerForClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay {
    UIViewController *newViewController = nil;
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    switch (_klass.formattedClassType) {
        case kRJParseClassTypeNone:
            break;
        case kRJParseClassTypeChoreographed: {
            RJChoreographedPlayingClassViewController *choreographedClassViewController = [[RJChoreographedPlayingClassViewController alloc] initWithNibName:nil bundle:nil];
            choreographedClassViewController.delegate = self;
            [choreographedClassViewController setKlass:_klass withAutoPlay:autoPlay];
            self.summaryView.trackArtwork.tintColor = nil;
            self.summaryView.trackArtwork.contentMode = UIViewContentModeScaleAspectFit;
            newViewController = choreographedClassViewController;
            break;
        }
        case kRJParseClassTypeSelfPaced: {
            RJSelfPacedPlayingClassViewController *selfPacedClassViewController = [[RJSelfPacedPlayingClassViewController alloc] init];
            selfPacedClassViewController.klass = _klass;
            self.summaryView.trackArtwork.image = [UIImage tintableImageNamed:@"selfPacedWorkoutIcon"];
            [self.summaryView.trackArtwork setTintColor:styleManager.themeBackgroundColor];
            self.summaryView.trackArtwork.contentMode = UIViewContentModeCenter;
            newViewController = selfPacedClassViewController;
            break;
        }
    }
    return newViewController;
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer {
    if (self.isMinimized) {
        self.minimized = !self.minimized;
        [self.delegate playingClassViewController:self delegateWillMinimize:self.minimized];
    }
}

- (void)infoButtonPressed:(UIButton *)button {
    RJClassDetailsViewController *detailsViewController = [[RJClassDetailsViewController alloc] initWithNibName:nil bundle:nil];
    detailsViewController.klass = self.klass;
    [[self navigationController] pushViewController:detailsViewController animated:YES];
}

- (void)minimizeButtonPressed:(UIButton *)button {
    if (!self.isMinimized) {
        self.minimized = !self.minimized;
        [self.delegate playingClassViewController:self delegateWillMinimize:self.minimized];
    }
}

- (void)playPauseButtonPressed:(UIButton *)button {
    if ([self.currentPlayingClassViewController isKindOfClass:[RJChoreographedPlayingClassViewController class]]) {
        RJChoreographedPlayingClassViewController *choreographedClassViewController = (RJChoreographedPlayingClassViewController *)self.currentPlayingClassViewController;
        [choreographedClassViewController playOrPauseCurrentClass];
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _summaryView = [[RJClassSummaryView alloc] initWithFrame:CGRectZero];
        _summaryView.trackArtwork.backgroundColor = [RJStyleManager sharedInstance].themeTextColor;
        _titleView = [[RJStackedTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *summaryView = self.summaryView;
    summaryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:summaryView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(summaryView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[summaryView(44)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[summaryView]|" options:0 metrics:nil views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem minimizeBarButtonItemWithTarget:self action:@selector(minimizeButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:styleManager.accentColor];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem toggleBarButtonItemWithTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:styleManager.accentColor];
    
    [self.summaryView.playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleView.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.detailTextLabel.textColor = styleManager.themeTextColor;
    self.titleView.detailTextLabel.font = styleManager.verySmallBoldFont;
    
    self.titleView.textLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.textLabel.textColor = styleManager.themeTextColor;
    self.titleView.textLabel.font = styleManager.navigationBarFont;
    
    self.summaryView.backgroundColor = styleManager.themeBackgroundColor;
    self.summaryView.layer.borderWidth = 0.5f;
    self.summaryView.layer.borderColor = styleManager.themeTextColor.CGColor;
    
    self.summaryView.playPauseButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.summaryView.playPauseButton.imageEdgeInsets =UIEdgeInsetsMake(3.0f, 3.0f, 7.0f, 0.0f);
    [self.summaryView.playPauseButton setTintColor:[UIColor whiteColor]];
    [self.summaryView.playPauseButton setTintColor:styleManager.themeTextColor];
    
    self.summaryView.classTitle.font = styleManager.verySmallBoldFont;
    self.summaryView.classTitle.textColor = styleManager.themeTextColor;
    
    self.summaryView.track.font = styleManager.verySmallFont;
    self.summaryView.track.textColor = styleManager.themeTextColor;
    
    self.view.backgroundColor = styleManager.themeBackgroundColor;
}

@end
