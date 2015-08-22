//
//  RJSortOptionsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/2/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryCell.h"
#import "RJInsetLabel.h"
#import "RJParseCategory.h"
#import "RJParseUtils.h"
#import "RJSortOptionsViewController.h"
#import "RJStyleManager.h"

static NSString *const kSortOptionsCellID = @"SortOptionsCellID";
static const CGFloat kCellSideSpacing = 13.0f;


@interface RJSortOptionsViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end


@implementation RJSortOptionsViewController


#pragma mark - Public Protocols - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static RJInsetLabel *sizingLabel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingLabel = [[RJInsetLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds))];
    });
    [self configureTitleLabelForCell:sizingLabel indexPath:indexPath];
    CGFloat width = ([sizingLabel sizeThatFits:sizingLabel.bounds.size].width + 2.0f*kCellSideSpacing);
    return CGSizeMake(width, CGRectGetHeight(collectionView.bounds));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

#pragma mark Public Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.categories count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSortOptionsCellID forIndexPath:indexPath];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

#pragma mark Public Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *previouslySelectedCell = [collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    previouslySelectedCell.selected = NO;
    
    self.selectedIndexPath = indexPath;
    UICollectionViewCell *newlySelectedCell = [collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    newlySelectedCell.selected = YES;
    
    [self.sortOptionsDelegate sortOptionsViewController:self didSelectCategory:self.categories[indexPath.section]];
}

#pragma mark - Public Instance Methods

- (void)configureTitleLabelForCell:(RJInsetLabel *)titleLabel indexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    titleLabel.font = styleManager.verySmallBoldFont;
    titleLabel.insets = UIEdgeInsetsMake(2.0f, 4.0f, 2.0f, 4.0f);
    titleLabel.text = [self.categories[indexPath.section] name];
    titleLabel.numberOfLines = 1;
}

- (void)configureCell:(RJGalleryCell *)galleryCell indexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    galleryCell.mask = NO;
    galleryCell.disableDuringLoading = NO;
    galleryCell.haveSelectedTitle = YES;
    galleryCell.backgroundView.backgroundColor = [UIColor clearColor];
    galleryCell.selectedTitleColor = styleManager.themeBackgroundColor;
    galleryCell.unselectedTitleColor = styleManager.themeTextColor;
    galleryCell.selectedTitleBackgroundColor = styleManager.themeTextColor;
    galleryCell.unselectedTitleBackgroundColor = styleManager.themeBackgroundColor;
    galleryCell.selected = [indexPath isEqual:self.selectedIndexPath];
    
    [self configureTitleLabelForCell:galleryCell.title indexPath:indexPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.collectionView registerClass:[RJGalleryCell class] forCellWithReuseIdentifier:kSortOptionsCellID];
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [RJParseUtils fetchAllCategoriesWithCompletion:^(NSArray *categories) {
        self.categories = categories;
        [self.collectionView reloadData];
        if (categories && ([categories count] > 0)) {
            [self.sortOptionsDelegate sortOptionsViewController:self didSelectCategory:self.categories[0]];
        }
    }];
}

#pragma mark - Public Instance Methods - Init

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return [super initWithCollectionViewLayout:layout];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    return [self init];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

@end
