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


@interface RJSortOptionsViewController ()

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end


@implementation RJSortOptionsViewController

#pragma mark Public Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.categories count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
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

- (void)configureCell:(RJGalleryCell *)galleryCell indexPath:(NSIndexPath *)indexPath {
    [super configureCell:galleryCell indexPath:indexPath];

    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    galleryCell.mask = NO;
    galleryCell.haveSelectedTitle = YES;
    
    galleryCell.backgroundView.backgroundColor = [UIColor clearColor];
    galleryCell.selectedTitleColor = styleManager.themeBackgroundColor;
    galleryCell.unselectedTitleColor = styleManager.themeTextColor;
    galleryCell.selectedTitleBackgroundColor = styleManager.themeTextColor;
    galleryCell.unselectedTitleBackgroundColor = styleManager.themeBackgroundColor;
    galleryCell.title.font = styleManager.verySmallBoldFont;
    galleryCell.title.insets = UIEdgeInsetsMake(2.0f, 4.0f, 2.0f, 4.0f);

    galleryCell.title.text = [self.categories[indexPath.section] name];
    
    galleryCell.selected = [indexPath isEqual:self.selectedIndexPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;

    self.itemsPerRow = 3.5f;
    self.spaced = NO;
    
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

@end
