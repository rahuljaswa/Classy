//
//  RJExerciseStepsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJExerciseStepCell.h"
#import "RJExerciseStepImageCacheEntity.h"
#import "RJExerciseStepsViewController.h"
#import "RJParseExercise.h"
#import "RJParseExerciseStep.h"
#import "RJStyleManager.h"
#import "UIImageView+FastImageCache.h"
#import <UIToolkitIOS/RJInsetLabel.h>

static NSString *const kExerciseStepsViewControllerCellID = @"ExerciseStepsViewControllerCellID";


@interface RJExerciseStepsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end


@implementation RJExerciseStepsViewController

#pragma mark - Public Properties

- (void)setExercise:(RJParseExercise *)exercise {
    _exercise = exercise;
    self.navigationItem.title = [_exercise.title uppercaseString];
    self.pageControl.numberOfPages = [_exercise.steps count];
    self.pageControl.currentPage = 0;
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.pageControl.currentPage = indexPath.item;
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

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.exercise.steps count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJExerciseStepCell *cell = (RJExerciseStepCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kExerciseStepsViewControllerCellID forIndexPath:indexPath];
    RJParseExerciseStep *step = self.exercise.steps[indexPath.item];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    if (step.image) {
        NSURL *url = [NSURL URLWithString:step.image.url];
        RJExerciseStepImageCacheEntity *entity = [[RJExerciseStepImageCacheEntity alloc] initWithImageURL:url objectID:step.objectId];
        [cell.image setImageEntity:entity formatName:kRJExerciseStepImageFormatFullScreen16BitBGR placeholder:nil];
    } else {
        cell.image.image = nil;
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = step.textDescription;
    cell.textLabel.font = styleManager.smallFont;
    cell.textLabel.textColor = styleManager.themeTextColor;
    cell.textLabel.insets = UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f);
    
    return cell;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return self;
}

- (instancetype)init {
    return [self initWithNibName:nil bundle:nil];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *collectionView = self.collectionView;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:collectionView];
    
    UIView *pageControl = self.pageControl;
    pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pageControl];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(collectionView, pageControl);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[pageControl(25)]-10-[collectionView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageControl]|" options:0 metrics:nil views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    
    [self.collectionView registerClass:[RJExerciseStepCell class] forCellWithReuseIdentifier:kExerciseStepsViewControllerCellID];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    
    self.pageControl.pageIndicatorTintColor = [RJStyleManager sharedInstance].themeTextColor;
    self.pageControl.currentPageIndicatorTintColor = [RJStyleManager sharedInstance].accentColor;
}

@end
