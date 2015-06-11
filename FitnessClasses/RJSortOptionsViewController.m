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


static NSString * const kCellID = @"cellID";

typedef NS_ENUM(NSUInteger, Section) {
    kSectionGeneric,
    kSectionSpecific,
    kNumSections
};

typedef NS_ENUM(NSUInteger, GenericSectionItem) {
    kGenericSectionItemNew,
    kGenericSectionItemPopular,
    kNumGenericSectionItems
};


@interface RJSortOptionsViewController ()

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end


@implementation RJSortOptionsViewController

#pragma mark Public Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfSections = 0;
    
    Section sortSection = section;
    switch (sortSection) {
        case kSectionGeneric:
            numberOfSections = kNumGenericSectionItems;
            break;
        case kSectionSpecific:
            numberOfSections = [self.categories count];
            break;
        default:
            break;
    }
    return numberOfSections;
}

#pragma mark Public Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *previouslySelectedCell = [collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    previouslySelectedCell.selected = NO;
    
    self.selectedIndexPath = indexPath;
    UICollectionViewCell *newlySelectedCell = [collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    newlySelectedCell.selected = YES;
    
    Section sortSection = self.selectedIndexPath.section;
    switch (sortSection) {
        case kSectionGeneric: {
            GenericSectionItem genericSectionItem = indexPath.item;
            switch (genericSectionItem) {
                case kGenericSectionItemNew:
                    [self.sortOptionsDelegate sortOptionsViewControllerDidSelectNew:self];
                    break;
                case kGenericSectionItemPopular:
                    [self.sortOptionsDelegate sortOptionsViewControllerDidSelectPopular:self];
                    break;
                default:
                    break;
            }
            break;
        }
        case kSectionSpecific:
            [self.sortOptionsDelegate sortOptionsViewController:self didSelectCategory:self.categories[indexPath.item]];
            break;
        default:
            break;
    }
}

#pragma mark - Public Instance Methods

- (void)configureCell:(RJGalleryCell *)galleryCell indexPath:(NSIndexPath *)indexPath {
    [super configureCell:galleryCell indexPath:indexPath];

    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    galleryCell.mask = NO;
    galleryCell.haveSelectedTitle = YES;
    
    galleryCell.backgroundView.backgroundColor = [UIColor clearColor];
    galleryCell.selectedTitleColor = styleManager.themeColor;
    galleryCell.unselectedTitleColor = styleManager.windowTintColor;
    galleryCell.selectedTitleBackgroundColor = styleManager.windowTintColor;
    galleryCell.unselectedTitleBackgroundColor = styleManager.themeColor;
    galleryCell.title.font = styleManager.smallBoldFont;
    galleryCell.title.insets = UIEdgeInsetsMake(2.0f, 4.0f, 2.0f, 4.0f);

    Section sortSection = indexPath.section;
    switch (sortSection) {
        case kSectionGeneric: {
            GenericSectionItem genericSectionItem = indexPath.item;
            switch (genericSectionItem) {
                case kGenericSectionItemNew:
                    galleryCell.title.text = NSLocalizedString(@"New", nil);
                    break;
                case kGenericSectionItemPopular:
                    galleryCell.title.text = NSLocalizedString(@"Popular", nil);
                    break;
                default:
                    break;
            }
            break;
        }
        case kSectionSpecific:
            galleryCell.title.text = [self.categories[indexPath.item] name];
            break;
        default:
            break;
    }
    
    galleryCell.selected = [indexPath isEqual:self.selectedIndexPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeColor;

    self.itemsPerRow = 3.5f;
    self.spaced = NO;
    
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [RJParseUtils fetchAllCategoriesWithCompletion:^(NSArray *categories) {
        self.categories = categories;
        [self.collectionView reloadData];
    }];
}

@end
