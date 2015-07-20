//
//  RJSelfPacedPlayingClassViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJExerciseInstructionCell.h"
#import "RJExerciseStepsViewController.h"
#import "RJParseClass.h"
#import "RJParseExercise.h"
#import "RJParseExerciseInstruction.h"
#import "RJSelfPacedPlayingClassViewController.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"

static NSString *const kCellID = @"cellID";


@interface RJSelfPacedPlayingClassViewController () <RJExerciseInstructionCellDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableIndexSet *completedSteps;

@property (nonatomic, strong, readonly) UIImageView *instructorPicture;
@property (nonatomic, strong, readonly) UILabel *instructorName;
@property (nonatomic, strong, readonly) UIButton *tipButton;

@end


@implementation RJSelfPacedPlayingClassViewController

#pragma mark - Public Properties

- (void)setKlass:(RJParseClass *)klass {
    _klass = klass;
    _completedSteps = [[NSMutableIndexSet alloc] init];
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - RJExerciseInstructionCellDelegate

- (void)exerciseInstructionCellDidSelectLeftSideAccessoryButton:(RJExerciseInstructionCell *)exerciseInstructionCell {
    NSUInteger index = [self.klass.exerciseInstructions indexOfObject:exerciseInstructionCell.exerciseInstruction];
    if ([self.completedSteps containsIndex:index]) {
        exerciseInstructionCell.leftSideAccessoryButton.selected = NO;
        [self.completedSteps removeIndex:index];
    } else {
        exerciseInstructionCell.leftSideAccessoryButton.selected = YES;
        [self.completedSteps addIndex:index];
    }
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJParseExerciseInstruction *instruction = self.klass.exerciseInstructions[indexPath.item];
    RJParseExercise *exercise = instruction.exercise;
    if (exercise.steps && ([exercise.steps count] > 0)) {
        RJExerciseStepsViewController *stepsViewController = [[RJExerciseStepsViewController alloc] init];
        stepsViewController.exercise = exercise;
        [[self navigationController] pushViewController:stepsViewController animated:YES];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Protocols - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.klass.exerciseInstructions count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJExerciseInstructionCell *cell = (RJExerciseInstructionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Private Protocols - UICollectionViewFlowLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static RJExerciseInstructionCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[RJExerciseInstructionCell alloc] initWithFrame:CGRectZero];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    CGFloat height = [sizingCell sizeThatFits:CGSizeMake(CGRectGetWidth(collectionView.bounds), CGFLOAT_MAX)].height;
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), height);
}

#pragma mark - Private Instance Methods

- (void)configureCell:(RJExerciseInstructionCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    cell.exerciseInstruction = self.klass.exerciseInstructions[indexPath.item];
    
    cell.backgroundColor = styleManager.themeBackgroundColor;
    
    [cell.leftSideAccessoryButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateNormal];
    [cell.leftSideAccessoryButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateHighlighted];
    [cell.leftSideAccessoryButton setBackgroundImage:[UIImage imageWithColor:styleManager.accentColor] forState:UIControlStateSelected];
    [cell.leftSideAccessoryButton setImage:[UIImage tintableImageNamed:@"checkIcon"] forState:UIControlStateNormal];
    cell.leftSideAccessoryButton.imageView.tintColor = styleManager.themeTextColor;
    cell.leftSideAccessoryButton.selected = [self.completedSteps containsIndex:indexPath.item];
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[RJExerciseInstructionCell class] forCellWithReuseIdentifier:kCellID];
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    self.collectionView.alwaysBounceVertical = YES;
}

@end
