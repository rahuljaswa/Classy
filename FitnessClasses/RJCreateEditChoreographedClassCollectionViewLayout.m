//
//  RJCreateEditChoreographedClassCollectionViewLayout.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateEditChoreographedClassCollectionViewLayout.h"
#import "RJCreateEditChoreographedClassExerciseInstructionCell.h"
#import "RJCreateEditChoreographedClassTimeline.h"
#import "RJCreateEditChoreographedClassViewController.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseTrack.h"

CGFloat kCreateEditChoreographedClassCollectionViewLayoutTickLength = 30.0f;

static CGFloat kLengthToDurationMultiplier = 2.4f;
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
@property (nonatomic, strong) NSArray *timelineAttributes;
@property (nonatomic, strong) NSArray *tracksAttributes;

@end


@implementation RJCreateEditChoreographedClassCollectionViewLayout

#pragma mark - Private Instance Methods

- (NSArray *)allItemLayoutAttributes {
    NSMutableArray *allItemLayoutAttributes = [[NSMutableArray alloc] init];
    [allItemLayoutAttributes addObjectsFromArray:self.categoryAttributes];
    [allItemLayoutAttributes addObjectsFromArray:self.createAttributes];
    [allItemLayoutAttributes addObjectsFromArray:self.nameAttributes];
    [allItemLayoutAttributes addObjectsFromArray:self.instructorAttributes];
    [allItemLayoutAttributes addObjectsFromArray:self.addTracksAttributes];
    [allItemLayoutAttributes addObjectsFromArray:self.addExerciseInstructionsAttributes];
    [allItemLayoutAttributes addObjectsFromArray:self.tracksAttributes];
    [allItemLayoutAttributes addObjectsFromArray:self.exerciseInstructionsAttributes];
    return allItemLayoutAttributes;
}

- (void)cacheLayoutAttributesIfNecessary {
    RJCreateEditChoreographedClassViewController *classViewController = (RJCreateEditChoreographedClassViewController *)self.collectionView.dataSource;
    if (([self.nameAttributes count] != 1) ||
        ([self.instructorAttributes count] != 1) ||
        ([self.categoryAttributes count] != 1) ||
        ([self.addExerciseInstructionsAttributes count] != 1) ||
        ([self.addTracksAttributes count] != 1) ||
        ([classViewController.exerciseInstructions count] != [self.exerciseInstructionsAttributes count]) ||
        ([classViewController.tracks count] != [self.tracksAttributes count]))
    {
        [self cacheLayoutAttributes];
    }
}

- (void)cacheLayoutAttributes {
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
    
    CGFloat tickWidthBuffer = (kCreateEditChoreographedClassCollectionViewLayoutTickLength/2.0f + 15.0f);
    
    for (NSUInteger i = 0; i < numberOfSections; i++) {
        RJCreateEditChoreographedClassViewControllerSection section = i;
        NSUInteger numberOfItems = [classViewController collectionView:self.collectionView numberOfItemsInSection:section];
        CGFloat yForSection = [[self class] yForSection:section];
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
                    layoutAttribute.frame = CGRectMake(tracksCellWidth+tickWidthBuffer, baseY + [[self class] lengthForDuration:[instruction.startPoint integerValue]], exerciseInstructionsCellWidth-tickWidthBuffer, [[self class] lengthForDuration:30]);
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
                    NSInteger lengthForDuration = [[self class] lengthForDuration:duration];
                    layoutAttribute.frame = CGRectMake(0.0f, baseY + startPointYForTrack, tracksCellWidth-tickWidthBuffer, lengthForDuration);
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

#pragma mark - Private Class Methods

+ (CGFloat)yForSection:(RJCreateEditChoreographedClassViewControllerSection)section {
    if (section == kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions) {
        return [self yForSection:kRJCreateEditChoreographedClassViewControllerSectionTracks];
    } else {
        return (kTopMargin+section*(kDefaultCellHeight+kTopMargin));
    }
}

#pragma mark - Public Instance Methods

- (void)prepareLayout {
    [super prepareLayout];
    [self cacheLayoutAttributes];
    self.timelineAttributes = nil;
}

- (CGSize)collectionViewContentSize {
    [self cacheLayoutAttributesIfNecessary];

    CGFloat maxY = 0.0f;
    
    NSArray *allItemLayoutAttributes = [self allItemLayoutAttributes];
    for (UICollectionViewLayoutAttributes *attributes in allItemLayoutAttributes) {
        CGFloat attributesMaxY = CGRectGetMaxY(attributes.frame);
        if (attributesMaxY > maxY) { maxY = attributesMaxY; }
    }
    
    CGFloat height = [[self class] yForSection:kRJCreateEditChoreographedClassViewControllerSectionAddTrack];
    height += [[self class] lengthForDuration:(60*60*1.5)];
    height += kBottomMargin;
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];

    UICollectionViewLayoutAttributes *timelineAttributes = [self layoutAttributesForSupplementaryViewOfKind:[RJCreateEditChoreographedClassTimeline kind] atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [layoutAttributes addObject:timelineAttributes];
    
    NSArray *allItemLayoutAttributes = [self allItemLayoutAttributes];
    for (UICollectionViewLayoutAttributes *attributes in allItemLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self cacheLayoutAttributesIfNecessary];
    
    UICollectionViewLayoutAttributes *attributesForIndexPath = nil;
    NSArray *allItemLayoutAttributes = [self allItemLayoutAttributes];
    for (UICollectionViewLayoutAttributes *attributes in allItemLayoutAttributes) {
        if ([attributes.indexPath isEqual:indexPath]) {
            attributesForIndexPath = attributes;
            break;
        }
    }
    return attributesForIndexPath;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = nil;
    if ([elementKind isEqualToString:[RJCreateEditChoreographedClassTimeline kind]]) {
        if (!self.timelineAttributes) {
            UICollectionViewLayoutAttributes *newAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:[RJCreateEditChoreographedClassTimeline kind] withIndexPath:indexPath];
            CGFloat originY = [[self class] yForSection:kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions];
            newAttributes.frame = CGRectMake(0.0f, originY, CGRectGetWidth(self.collectionView.bounds), [self collectionViewContentSize].height - originY);
            newAttributes.zIndex = -2;
            self.timelineAttributes = @[newAttributes];
        }
        attributes = [self.timelineAttributes lastObject];
    }
    return attributes;
}

#pragma mark - Public Class Methods

+ (NSInteger)durationForLength:(CGFloat)length {
    return (NSInteger)(length/kLengthToDurationMultiplier);
}

+ (CGFloat)lengthForDuration:(NSInteger)duration {
    return (((CGFloat)duration)*kLengthToDurationMultiplier);
}

+ (NSInteger)startPointForOriginY:(CGFloat)originY {
    CGFloat length = (originY - [[self class] yForSection:kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions]);
    return [self durationForLength:MAX(0, length)];
}

@end
