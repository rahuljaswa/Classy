//
//  RJGalleryViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryCell.h"
#import "RJGalleryViewController.h"

static NSString *const kGalleryCellID = @"GalleryCellID";


@implementation RJGalleryViewController

#pragma mark - Public Properties

- (void)setItemsPerRow:(CGFloat)itemsPerRow {
    _itemsPerRow = itemsPerRow;
    [self.collectionView reloadData];
}

- (void)setSpaced:(BOOL)spaced {
    _spaced = spaced;
    [self.collectionView reloadData];
}

#pragma mark - Public Protocols - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.spaced) {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
        switch (flowLayout.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:
                return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 1.0f);
                break;
            case UICollectionViewScrollDirectionVertical:
                return UIEdgeInsetsMake(0.0f, 0.0f, 1.0f, 0.0f);
                break;
        }
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat usableWidth;
    if (self.itemsPerRow > 1.0f) {
        if (self.spaced) {
            usableWidth = (CGRectGetWidth(collectionView.bounds) - (self.itemsPerRow + 1.0f));
        } else {
            usableWidth = (CGRectGetWidth(collectionView.bounds) - self.itemsPerRow);
        }
    } else {
        usableWidth = CGRectGetWidth(collectionView.bounds);
    }
    CGFloat width = ceil(usableWidth/self.itemsPerRow);
    CGFloat height = width;
    return CGSizeMake(MIN(CGRectGetWidth(collectionView.bounds), width),
                      MIN(CGRectGetHeight(collectionView.bounds), height));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.spaced ? 1.0f : 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.spaced ? 1.0f : 0.0f;
}

#pragma mark - Public Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGalleryCellID forIndexPath:indexPath];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

#pragma mark - Public Instance Methods

- (void)configureCell:(RJGalleryCell *)galleryCell indexPath:(NSIndexPath *)indexPath {
    galleryCell.disableDuringLoading = NO;
    galleryCell.mask = YES;
    galleryCell.backgroundView.backgroundColor = [UIColor lightGrayColor];
}

- (instancetype)init {
    return [self initWithScrollDirection:UICollectionViewScrollDirectionVertical];
}

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = scrollDirection;
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _spaced = YES;
        _itemsPerRow = 1.0f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[RJGalleryCell class] forCellWithReuseIdentifier:kGalleryCellID];
}

@end
