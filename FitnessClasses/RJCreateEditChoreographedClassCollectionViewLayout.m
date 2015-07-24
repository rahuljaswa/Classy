//
//  RJCreateEditChoreographedClassCollectionViewLayout.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateEditChoreographedClassCollectionViewLayout.h"
#import "RJCreateEditChoreographedClassExerciseInstructionCell.h"
#import "RJCreateEditChoreographedClassViewController.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseTrack.h"

static CGFloat kTopMargin = 30.0f;
static CGFloat kBottomMargin = 30.0f;
static CGFloat kDefaultCellHeight = 44.0f;
static NSInteger kTrackDefaultLength = 180;


@interface RJCreateEditChoreographedClassCollectionViewLayout ()

@property (nonatomic, strong) NSArray *addExerciseInstructionsAttributes;
@property (nonatomic, strong) NSArray *addTracksAttributes;
@property (nonatomic, strong) NSArray *categoryAttributes;
@property (nonatomic, strong) NSArray *createAttributes;
@property (nonatomic, strong) NSArray *exerciseInstructionsAttributes;
@property (nonatomic, strong) NSArray *instructorAttributes;
@property (nonatomic, strong) NSArray *nameAttributes;
@property (nonatomic, strong) NSArray *tracksAttributes;

@end


@implementation RJCreateEditChoreographedClassCollectionViewLayout

#pragma mark - Private Instance Methods

- (CGFloat)lengthForDuration:(NSInteger)duration {
    return (((CGFloat)duration)*2.4f);
}

- (CGFloat)yForSection:(RJCreateEditChoreographedClassViewControllerSection)section {
    if (section == kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions) {
        return [self yForSection:kRJCreateEditChoreographedClassViewControllerSectionTracks];
    } else {
        return (kTopMargin+section*(kDefaultCellHeight+kTopMargin));
    }
}

- (NSArray *)allLayoutAttributes {
    NSMutableArray *allLayoutAttributes = [[NSMutableArray alloc] init];
    [allLayoutAttributes addObjectsFromArray:self.categoryAttributes];
    [allLayoutAttributes addObjectsFromArray:self.createAttributes];
    [allLayoutAttributes addObjectsFromArray:self.nameAttributes];
    [allLayoutAttributes addObjectsFromArray:self.instructorAttributes];
    [allLayoutAttributes addObjectsFromArray:self.addTracksAttributes];
    [allLayoutAttributes addObjectsFromArray:self.addExerciseInstructionsAttributes];
    [allLayoutAttributes addObjectsFromArray:self.tracksAttributes];
    [allLayoutAttributes addObjectsFromArray:self.exerciseInstructionsAttributes];
    return allLayoutAttributes;
}

- (void)cacheItemLayoutAttributesIfNecessary {
    RJCreateEditChoreographedClassViewController *classViewController = (RJCreateEditChoreographedClassViewController *)self.collectionView.dataSource;
    if (([self.nameAttributes count] != 1) ||
        ([self.instructorAttributes count] != 1) ||
        ([self.categoryAttributes count] != 1) ||
        ([self.addExerciseInstructionsAttributes count] != 1) ||
        ([self.addTracksAttributes count] != 1) ||
        ([classViewController.exerciseInstructions count] != [self.exerciseInstructionsAttributes count]) ||
        ([classViewController.tracks count] != [self.tracksAttributes count]))
    {
        [self cacheItemLayoutAttributes];
    }
}

- (void)cacheItemLayoutAttributes {
    NSMutableArray *nameAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *categoryAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *instructorAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *addExerciseInstructionsAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *addTracksAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *exerciseInstructionsAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *tracksAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *createAttributes = [[NSMutableArray alloc] init];
    
    RJCreateEditChoreographedClassViewController *classViewController = (RJCreateEditChoreographedClassViewController *)self.collectionView.dataSource;
    
    NSUInteger numberOfSections = [classViewController numberOfSectionsInCollectionView:self.collectionView];
    
    CGFloat tracksCellWidth = CGRectGetWidth(self.collectionView.bounds)/2.0f;
    CGFloat exerciseInstructionsCellWidth = CGRectGetWidth(self.collectionView.bounds)/2.0f;
    
    for (NSUInteger i = 0; i < numberOfSections; i++) {
        RJCreateEditChoreographedClassViewControllerSection section = i;
        NSUInteger numberOfItems = [classViewController collectionView:self.collectionView numberOfItemsInSection:section];
        CGFloat yForSection = [self yForSection:section];
        switch (section) {
            case kRJCreateEditChoreographedClassViewControllerSectionName: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [nameAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateEditChoreographedClassViewControllerSectionInstructor: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [instructorAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateEditChoreographedClassViewControllerSectionCategory: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [categoryAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateEditChoreographedClassViewControllerSectionAddTrack: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [addTracksAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateEditChoreographedClassViewControllerSectionAddExerciseInstruction: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [addExerciseInstructionsAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions: {
                CGFloat baseY = yForSection;
                for (NSUInteger j = 0; j < numberOfItems; j++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
                    RJParseExerciseInstruction *instruction = [classViewController.exerciseInstructions objectAtIndex:j];
                    UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                    layoutAttribute.frame = CGRectMake(tracksCellWidth, baseY + [self lengthForDuration:[instruction.startPoint integerValue]], exerciseInstructionsCellWidth, [self lengthForDuration:30]);
                    layoutAttribute.zIndex = indexPath.item;
                    [exerciseInstructionsAttributes addObject:layoutAttribute];
                }
                break;
            }
            case kRJCreateEditChoreographedClassViewControllerSectionTracks: {
                CGFloat baseY = yForSection;
                NSInteger startPointYForTrack = 0.0f;
                for (NSUInteger j = 0; j < numberOfItems; j++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
                    RJParseTrack *track = [classViewController.tracks objectAtIndex:j];
                    UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                    NSInteger duration = track.length ? [track.length integerValue] : kTrackDefaultLength;
                    NSInteger lengthForDuration = [self lengthForDuration:duration];
                    layoutAttribute.frame = CGRectMake(0.0f, baseY + startPointYForTrack, tracksCellWidth, lengthForDuration);
                    layoutAttribute.zIndex = indexPath.item;
                    [tracksAttributes addObject:layoutAttribute];
                    startPointYForTrack += lengthForDuration;
                }
                break;
            }
            case kRJCreateEditChoreographedClassViewControllerSectionCreate: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [createAttributes addObject:layoutAttribute];
                break;
            }
            default:
                break;
        }
    }
    
    self.categoryAttributes = categoryAttributes;
    self.createAttributes = createAttributes;
    self.nameAttributes = nameAttributes;
    self.instructorAttributes = instructorAttributes;
    self.addTracksAttributes = addTracksAttributes;
    self.addExerciseInstructionsAttributes = addExerciseInstructionsAttributes;
    self.tracksAttributes = tracksAttributes;
    self.exerciseInstructionsAttributes = exerciseInstructionsAttributes;
}

#pragma mark - Public Instance Methods

- (void)prepareLayout {
    [super prepareLayout];
    [self cacheItemLayoutAttributes];
}

- (CGSize)collectionViewContentSize {
    [self cacheItemLayoutAttributesIfNecessary];

    CGFloat maxY = 0.0f;
    
    NSArray *allLayoutAttributes = [self allLayoutAttributes];
    for (UICollectionViewLayoutAttributes *attributes in allLayoutAttributes) {
        CGFloat attributesMaxY = CGRectGetMaxY(attributes.frame);
        if (attributesMaxY > maxY) { maxY = attributesMaxY; }
    }
    
    CGFloat height = (maxY + kBottomMargin + self.collectionView.contentInset.top + self.collectionView.contentInset.bottom);
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
    NSArray *allLayoutAttributes = [self allLayoutAttributes];
    for (UICollectionViewLayoutAttributes *attributes in allLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self cacheItemLayoutAttributesIfNecessary];
    
    UICollectionViewLayoutAttributes *attributesForIndexPath = nil;
    NSArray *allLayoutAttributes = [self allLayoutAttributes];
    for (UICollectionViewLayoutAttributes *attributes in allLayoutAttributes) {
        if ([attributes.indexPath isEqual:indexPath]) {
            attributesForIndexPath = attributes;
            break;
        }
    }
    return attributesForIndexPath;
}

@end
