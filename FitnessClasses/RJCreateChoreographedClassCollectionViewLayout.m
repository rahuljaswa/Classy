//
//  RJCreateChoreographedClassCollectionViewLayout.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateChoreographedClassCollectionViewLayout.h"
#import "RJCreateChoreographedClassExerciseInstructionCell.h"
#import "RJCreateChoreographedClassViewController.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseTrack.h"
#import "RJParseTrackInstruction.h"

static CGFloat kTopMargin = 30.0f;
static CGFloat kBottomMargin = 30.0f;
static CGFloat kDefaultCellHeight = 44.0f;
static NSInteger kTrackInstructionDefaultLength = 180;


@interface RJCreateChoreographedClassCollectionViewLayout ()

@property (nonatomic, strong) NSArray *addExerciseInstructionsAttributes;
@property (nonatomic, strong) NSArray *addTrackInstructionsAttributes;
@property (nonatomic, strong) NSArray *categoryAttributes;
@property (nonatomic, strong) NSArray *createAttributes;
@property (nonatomic, strong) NSArray *exerciseInstructionsAttributes;
@property (nonatomic, strong) NSArray *instructorAttributes;
@property (nonatomic, strong) NSArray *nameAttributes;
@property (nonatomic, strong) NSArray *trackInstructionsAttributes;

@end


@implementation RJCreateChoreographedClassCollectionViewLayout

#pragma mark - Private Instance Methods

- (CGFloat)lengthForDuration:(NSInteger)duration {
    return (((CGFloat)duration)*2.2f);
}

- (CGFloat)yForSection:(RJCreateChoreographedClassViewControllerSection)section {
    if (section == kRJCreateChoreographedClassViewControllerSectionExerciseInstructions) {
        return [self yForSection:kRJCreateChoreographedClassViewControllerSectionTrackInstructions];
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
    [allLayoutAttributes addObjectsFromArray:self.addTrackInstructionsAttributes];
    [allLayoutAttributes addObjectsFromArray:self.addExerciseInstructionsAttributes];
    [allLayoutAttributes addObjectsFromArray:self.trackInstructionsAttributes];
    [allLayoutAttributes addObjectsFromArray:self.exerciseInstructionsAttributes];
    return allLayoutAttributes;
}

- (void)cacheItemLayoutAttributesIfNecessary {
    RJCreateChoreographedClassViewController *classViewController = (RJCreateChoreographedClassViewController *)self.collectionView.dataSource;
    if (([self.nameAttributes count] != 1) ||
        ([self.instructorAttributes count] != 1) ||
        ([self.categoryAttributes count] != 1) ||
        ([self.addExerciseInstructionsAttributes count] != 1) ||
        ([self.addTrackInstructionsAttributes count] != 1) ||
        ([classViewController.exerciseInstructions count] != [self.exerciseInstructionsAttributes count]) ||
        ([classViewController.trackInstructions count] != [self.trackInstructionsAttributes count]))
    {
        [self cacheItemLayoutAttributes];
    }
}

- (void)cacheItemLayoutAttributes {
    NSMutableArray *nameAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *categoryAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *instructorAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *addExerciseInstructionsAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *addTrackInstructionsAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *exerciseInstructionsAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *trackInstructionsAttributes = [[NSMutableArray alloc] init];
    NSMutableArray *createAttributes = [[NSMutableArray alloc] init];
    
    RJCreateChoreographedClassViewController *classViewController = (RJCreateChoreographedClassViewController *)self.collectionView.dataSource;
    
    NSUInteger numberOfSections = [classViewController numberOfSectionsInCollectionView:self.collectionView];
    
    CGFloat trackInstructionsCellWidth = CGRectGetWidth(self.collectionView.bounds)/2.0f;
    CGFloat exerciseInstructionsCellWidth = CGRectGetWidth(self.collectionView.bounds)/2.0f;
    
    for (NSUInteger i = 0; i < numberOfSections; i++) {
        RJCreateChoreographedClassViewControllerSection section = i;
        NSUInteger numberOfItems = [classViewController collectionView:self.collectionView numberOfItemsInSection:section];
        CGFloat yForSection = [self yForSection:section];
        switch (section) {
            case kRJCreateChoreographedClassViewControllerSectionName: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [nameAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateChoreographedClassViewControllerSectionInstructor: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [instructorAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateChoreographedClassViewControllerSectionCategory: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [categoryAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateChoreographedClassViewControllerSectionAddTrackInstruction: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [addTrackInstructionsAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateChoreographedClassViewControllerSectionAddExerciseInstruction: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttribute.frame = CGRectMake(0.0f, yForSection, CGRectGetWidth(self.collectionView.bounds), kDefaultCellHeight);
                [addExerciseInstructionsAttributes addObject:layoutAttribute];
                break;
            }
            case kRJCreateChoreographedClassViewControllerSectionExerciseInstructions: {
                CGFloat baseY = yForSection;
                for (NSUInteger j = 0; j < numberOfItems; j++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
                    RJParseExerciseInstruction *instruction = [classViewController.exerciseInstructions objectAtIndex:j];
                    UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                    layoutAttribute.frame = CGRectMake(trackInstructionsCellWidth, baseY + [self lengthForDuration:[instruction.startPoint integerValue]], exerciseInstructionsCellWidth, [self lengthForDuration:30]);
                    layoutAttribute.zIndex = indexPath.item;
                    [exerciseInstructionsAttributes addObject:layoutAttribute];
                }
                break;
            }
            case kRJCreateChoreographedClassViewControllerSectionTrackInstructions: {
                CGFloat baseY = yForSection;
                for (NSUInteger j = 0; j < numberOfItems; j++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
                    RJParseTrackInstruction *instruction = [classViewController.trackInstructions objectAtIndex:j];
                    UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                    NSInteger duration = instruction.track.length ? [instruction.track.length integerValue] : kTrackInstructionDefaultLength;
                    layoutAttribute.frame = CGRectMake(0.0f, baseY + [self lengthForDuration:[instruction.startPoint integerValue]], trackInstructionsCellWidth, [self lengthForDuration:duration]);
                    layoutAttribute.zIndex = indexPath.item;
                    [trackInstructionsAttributes addObject:layoutAttribute];
                }
                break;
            }
            case kRJCreateChoreographedClassViewControllerSectionCreate: {
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
    self.addTrackInstructionsAttributes = addTrackInstructionsAttributes;
    self.addExerciseInstructionsAttributes = addExerciseInstructionsAttributes;
    self.trackInstructionsAttributes = trackInstructionsAttributes;
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
