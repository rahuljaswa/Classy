//
//  RJExerciseEquipmentOptionsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/30/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJExerciseEquipmentOptionsViewController.h"
#import "RJGalleryCell.h"
#import "RJInsetLabel.h"
#import "RJParseExerciseEquipment.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"


@interface RJExerciseEquipmentOptionsViewController ()

@property (nonatomic, strong, readwrite) NSArray *equipment;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end


@implementation RJExerciseEquipmentOptionsViewController

#pragma mark - Public Properties

- (void)setEquipment:(NSArray *)equipment {
    _equipment = equipment;
    _selectedIndexPath = nil;
    [self selectEquipmentIfNecessary];
    [self.collectionView reloadData];
}

- (void)setSelectedEquipment:(RJParseExerciseEquipment *)selectedEquipment {
    _selectedEquipment = selectedEquipment;
    if (self.equipment) {
        [self selectEquipmentIfNecessary];
    }
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    _selectedIndexPath = selectedIndexPath;
    self.selectedEquipment = self.equipment[self.selectedIndexPath.section];
    [self.exerciseEquipmentOptionsDelegate exerciseEquipmentOptionsViewController:self didSelectExerciseEquipment:self.selectedEquipment];
}

#pragma mark - Public Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.equipment count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJGalleryCell *cell = (RJGalleryCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = [self.selectedIndexPath isEqual:indexPath];
    return cell;
}

#pragma mark - Public Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *previouslySelectedCell = [collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    previouslySelectedCell.selected = NO;
    
    self.selectedIndexPath = indexPath;
    
    UICollectionViewCell *newlySelectedCell = [self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    newlySelectedCell.selected = YES;
}

#pragma mark - Private Instance Methods

- (void)selectEquipmentIfNecessary {
    BOOL isEquipmentAlreadySelected = [self.equipment[self.selectedIndexPath.section] isEqual:self.selectedEquipment];
    if (self.equipment && self.selectedEquipment && !isEquipmentAlreadySelected) {
        NSInteger indexOfEquipment = [self.equipment indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            RJParseExerciseEquipment *equipment = obj;
            return [equipment.objectId isEqualToString:self.selectedEquipment.objectId];
        }];
        if (indexOfEquipment != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:indexOfEquipment];
            self.selectedIndexPath = indexPath;
            [self.collectionView reloadData];
        }
    }
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
    
    galleryCell.title.text = [self.equipment[indexPath.section] name];
    
    galleryCell.selected = [indexPath isEqual:self.selectedIndexPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    
    CGFloat deviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    // iphone 6+ = 736.0f
    // iphone 6 = 667
    // iphone 5 = 568
    // iphone 4 = 480
    if (deviceHeight > 568.0f) {
        self.itemsPerRow = 3.5f;
    } else {
        self.itemsPerRow = 2.5f;
    }
    
    self.spaced = NO;
    
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [RJParseUtils fetchAllEquipmentWithCompletion:^(NSArray *equipment) {
        self.equipment = equipment;
        [self.collectionView reloadData];
        if (equipment && ([equipment count] > 0) && !self.selectedIndexPath) {
            self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        }
    }];
}

@end
