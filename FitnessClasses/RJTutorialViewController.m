//
//  RJTutorialViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/15/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJInsetLabel.h"
#import "RJStyleManager.h"
#import "RJTutorialCollectionViewCell.h"
#import "RJTutorialViewController.h"
#import "UIColor+RJAdditions.h"
#import "UIImage+RJAdditions.h"

static NSString *const kRJTutorialViewControllerCellID = @"RJTutorialViewControllerCellID";

typedef NS_ENUM(NSInteger, TutorialPage) {
    kTutorialPageWelcome,
    kTutorialPageChoreographed,
    kTutorialPageSelfPaced,
    kTutorialPageGetStarted,
    kTutorialPageStarting,
    kNumTutorialPages
};


@interface RJTutorialViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) UIButton *button;

@end


@implementation RJTutorialViewController

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kNumTutorialPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJTutorialCollectionViewCell *cell = (RJTutorialCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRJTutorialViewControllerCellID forIndexPath:indexPath];
    
    [cell.button addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.tintColor = styleManager.themeBackgroundColor;
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = styleManager.themeBackgroundColor;
    
    cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    cell.detailTextLabel.textColor = styleManager.themeBackgroundColor;
    
    CGFloat deviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    // iphone 6+ = 736.0f
    // iphone 6 = 667
    // iphone 5 = 568
    // iphone 4 = 480
    if (deviceHeight > 568.0f) {
        cell.textLabel.font = styleManager.largeBoldFont;
        cell.textLabel.insets = UIEdgeInsetsMake(0.0f, 20.0f, 5.0f, 20.0f);
        cell.detailTextLabel.font = styleManager.mediumFont;
        cell.detailTextLabel.insets = UIEdgeInsetsMake(0.0f, 20.0f, 30.0f, 20.0f);
    } else {
        cell.textLabel.font = styleManager.mediumBoldFont;
        cell.textLabel.insets = UIEdgeInsetsMake(10.0f, 20.0f, 5.0f, 20.0f);
        cell.detailTextLabel.font = styleManager.smallFont;
        cell.detailTextLabel.insets = UIEdgeInsetsMake(0.0f, 20.0f, 20.0f, 20.0f);
    }
    
    cell.button.layer.borderColor = styleManager.themeBackgroundColor.CGColor;
    cell.button.layer.cornerRadius = 5.0f;
    cell.button.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    cell.button.titleLabel.font = styleManager.mediumBoldFont;
    cell.button.clipsToBounds = YES;
    
    TutorialPage tutorialPage = indexPath.item;
    switch (tutorialPage) {
        case kTutorialPageWelcome:
            cell.textLabel.text = NSLocalizedString(@"Welcome to Classy", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Free fitness classes and workouts designed by world-class trainers and scientists.", nil);
            cell.imageView.image = [UIImage imageNamed:@"tutorialWelcomeImage"];
            [cell.button setBackgroundImage:nil forState:UIControlStateNormal];
            [cell.button setTitle:nil forState:UIControlStateNormal];
            cell.button.layer.borderWidth = 0.0f;
            cell.button.userInteractionEnabled = NO;
            break;
        case kTutorialPageChoreographed:
            cell.textLabel.text = NSLocalizedString(@"Fitness Classes", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Try a choreographed class, complete with voice instructions and bumping music.", nil);
            cell.imageView.image = [UIImage imageNamed:@"tutorialChoreographedImage"];
            [cell.button setBackgroundImage:nil forState:UIControlStateNormal];
            [cell.button setTitle:nil forState:UIControlStateNormal];
            cell.button.layer.borderWidth = 0.0f;
            cell.button.userInteractionEnabled = NO;
            break;
        case kTutorialPageSelfPaced:
            cell.textLabel.text = NSLocalizedString(@"Workouts", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Do a self-paced workout. Check things off with one click.", nil);
            cell.imageView.image = [UIImage imageNamed:@"tutorialSelfPacedImage"];
            [cell.button setBackgroundImage:nil forState:UIControlStateNormal];
            [cell.button setTitle:nil forState:UIControlStateNormal];
            cell.button.layer.borderWidth = 0.0f;
            cell.button.userInteractionEnabled = NO;
            break;
        case kTutorialPageGetStarted:
            cell.textLabel.text = NSLocalizedString(@"Don't Hesitate!", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Millions have lost weight and gained muscle using our approach.", nil);
            cell.imageView.image = [UIImage tintableImageNamed:@"appIcon"];
            [cell.button setTitle:NSLocalizedString(@"Get Started", nil) forState:UIControlStateNormal];
            [cell.button setBackgroundImage:nil forState:UIControlStateNormal];
            [cell.button setBackgroundImage:[UIImage imageWithColor:styleManager.themeBackgroundColor] forState:UIControlStateHighlighted];
            [cell.button setTitleColor:styleManager.themeBackgroundColor forState:UIControlStateNormal];
            [cell.button setTitleColor:styleManager.themeTextColor forState:UIControlStateHighlighted];
            cell.button.layer.borderWidth = 1.0f;
            cell.button.userInteractionEnabled = YES;
            break;
        case kTutorialPageStarting:
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
            [cell.button setTitle:nil forState:UIControlStateNormal];
            cell.button.layer.borderWidth = 0.0f;
            cell.button.userInteractionEnabled = NO;
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.bounds);
    CGFloat xOffset = scrollView.contentOffset.x;
    
    TutorialPage leftPage = floor(xOffset/pageWidth);
    TutorialPage rightPage = ceil(xOffset/pageWidth);
    
    self.button.userInteractionEnabled = (leftPage == rightPage);
    
    if (rightPage == kTutorialPageStarting) {
        [self.tutorialDelegate tutorialViewControllerDidFinish:self];
    } else {
        CGFloat distance = (fmodf(xOffset, pageWidth)/pageWidth);
        if (rightPage == kTutorialPageGetStarted) {
            self.button.alpha = (distance == 0.0f) ? 0.0f : (1.0f-distance);
        }
        self.collectionView.backgroundColor = [self colorForDistance:distance betweenTutorialPage:leftPage andTutorialPage:rightPage];
    }
}

#pragma mark - Private Protocols - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - Private Instance Methods

- (UIColor *)colorForDistance:(CGFloat)distance betweenTutorialPage:(TutorialPage)tutorialPage andTutorialPage:(TutorialPage)otherTutorialPage {
    UIColor *tutorialPageColor = [self rgbColorForTutorialPage:tutorialPage];
    UIColor *otherTutorialPageColor = [self rgbColorForTutorialPage:otherTutorialPage];
    return [UIColor colorForDistance:distance betweenColor:tutorialPageColor andColor:otherTutorialPageColor];
}

- (UIColor *)rgbColorForTutorialPage:(TutorialPage)tutorialPage {
    UIColor *rgbColor = nil;
    switch (tutorialPage) {
        case kTutorialPageWelcome:
            rgbColor = [UIColor colorWithRed:53.0f/255.0f green:189.0f/255.0f blue:144.0f/255.0f alpha:1.0f];
            break;
        case kTutorialPageChoreographed:
            rgbColor = [UIColor colorWithRed:122.0f/255.0f green:135.0f/255.0f blue:168.0f/255.0f alpha:1.0f];
            break;
        case kTutorialPageSelfPaced:
            rgbColor = [UIColor colorWithRed:244.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
            break;
        case kTutorialPageGetStarted:
            rgbColor = [RJStyleManager sharedInstance].accentColor;
            break;
        case kTutorialPageStarting:
            rgbColor = [RJStyleManager sharedInstance].accentColor;
            break;
        default:
            break;
    }
    return rgbColor;
}

- (void)cellButtonPressed:(UIButton *)button {
    [self.tutorialDelegate tutorialViewControllerDidFinish:self];
}

- (void)nextButtonPressed:(UIButton *)button {
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:(currentIndexPath.item + 1) inSection:currentIndexPath.section];
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return [super initWithCollectionViewLayout:layout];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[RJTutorialCollectionViewCell class] forCellWithReuseIdentifier:kRJTutorialViewControllerCellID];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.backgroundColor = [self rgbColorForTutorialPage:kTutorialPageWelcome];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.button];
    [self.button addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    [self.button setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    self.button.titleLabel.font = styleManager.mediumBoldFont;
    [self.button setTitleColor:styleManager.themeBackgroundColor forState:UIControlStateNormal];
    [self.button setTitleColor:styleManager.themeBackgroundColor forState:UIControlStateHighlighted];
    
    UIView *button = self.button;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(button);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[button]" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button]-15-|" options:0 metrics:nil views:views]];
    
    [self.view bringSubviewToFront:button];
}

@end
