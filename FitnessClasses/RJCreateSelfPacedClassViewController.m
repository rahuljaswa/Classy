//
//  RJSingleSelectionViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateSelfPacedClassViewController.h"
#import "RJCreateSelfPacedExerciseInstructionCell.h"
#import "RJSingleSelectionViewController.h"
#import "RJLabelCell.h"
#import "RJMusclesViewController.h"
#import "RJParseCategory.h"
#import "RJParseExercise.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseUtils.h"
#import "RJSingleSelectionViewController.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"
#import <SZTextView/SZTextView.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kLabelCellID = @"LabelCellID";
static NSString *const kCreateExerciseInstructionCellID = @"CreateExerciseInstructionCellID";
static const CGFloat kLabelCellHeight = 44.0f;
static const CGFloat kCreateExerciseInstructionCellHeight = 120.0f;

typedef NS_ENUM(NSInteger, Section) {
    kSectionAddInstruction,
    kSectionInstructions,
    kSectionName,
    kSectionCategory,
    kSectionCreate,
    kNumSections
};


@interface RJCreateSelfPacedClassViewController () <RJCreateSelfPacedExerciseInstructionCellDelegate, RJSingleSelectionViewControllerDataSource, RJSingleSelectionViewControllerDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong, readonly) RJSingleSelectionViewController *categoryViewController;
@property (nonatomic, strong, readonly) NSMutableArray *exerciseInstructions;
@property (nonatomic, strong) NSArray *exercises;
@property (nonatomic, strong) NSString *name;

@end


@implementation RJCreateSelfPacedClassViewController

@synthesize categoryViewController = _categoryViewController;

#pragma mark - Private Properties

- (RJSingleSelectionViewController *)categoryViewController {
    if (!_categoryViewController) {
        _categoryViewController = [[RJSingleSelectionViewController alloc] init];
        _categoryViewController.navigationItem.title = [NSLocalizedString(@"Pick Category", nil) uppercaseString];
        _categoryViewController.dataSource = self;
        [RJParseUtils fetchAllCategoriesWithCompletion:^(NSArray *equipment) {
            _categoryViewController.objects = equipment;
        }];
    }
    return _categoryViewController;
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDelegate

- (void)singleSelectionViewController:(RJSingleSelectionViewController *)viewController didSelectObject:(NSObject *)object {
    RJParseExerciseInstruction *instruction = self.exerciseInstructions[viewController.view.tag];
    instruction.exercise = (RJParseExercise *)object;
    [self.collectionView reloadData];
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSingleSelectionViewController *)viewController titleForObject:(NSObject *)object {
    if (viewController == self.categoryViewController) {
        RJParseCategory *category = (RJParseCategory *)object;
        return category.name;
    } else {
        RJParseExercise *exercise = (RJParseExercise *)object;
        return exercise.title;
    }
}

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    
    Section createSection = section;
    switch (createSection) {
        case kSectionName:
            numberOfItems = 1;
            break;
        case kSectionCategory:
            numberOfItems = 1;
            break;
        case kSectionAddInstruction:
            numberOfItems = 1;
            break;
        case kSectionInstructions:
            numberOfItems = [self.exerciseInstructions count];
            break;
        case kSectionCreate:
            numberOfItems = 1;
            break;
        default:
            break;
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    Section createSection = indexPath.section;
    switch (createSection) {
        case kSectionName: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.style = kRJLabelCellStyleTextField;
            labelCell.textField.delegate = self;
            labelCell.textField.placeholder = NSLocalizedString(@"Name", nil);
            labelCell.textField.font = styleManager.smallFont;
            labelCell.textField.textColor = styleManager.themeTextColor;
            labelCell.textField.text = self.name;
            labelCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            labelCell.accessoryView.image = nil;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kSectionCategory: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.textLabel.text = NSLocalizedString(@"Category", nil);
            labelCell.textLabel.textAlignment = NSTextAlignmentLeft;
            labelCell.accessoryView.image = [UIImage imageNamed:@"forwardIcon"];
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kSectionAddInstruction: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.text = NSLocalizedString(@"Add Instruction", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = [UIColor clearColor];
            cell = labelCell;
            break;
        }
        case kSectionInstructions: {
            RJCreateSelfPacedExerciseInstructionCell *instructionCell = (RJCreateSelfPacedExerciseInstructionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCreateExerciseInstructionCellID forIndexPath:indexPath];
            instructionCell.delegate = self;
            RJParseExerciseInstruction *instruction = self.exerciseInstructions[indexPath.item];
            instructionCell.exerciseInstruction = instruction;
            
            NSString *title = instruction.exercise ? instruction.exercise.title : NSLocalizedString(@"Exercise", nil);
            [instructionCell.exerciseButton setTitle:title forState:UIControlStateNormal];
            [instructionCell.exerciseButton setTitleColor:styleManager.themeTextColor forState:UIControlStateNormal];
            instructionCell.exerciseButton.titleLabel.font = styleManager.smallBoldFont;
            instructionCell.beginnerQuantityTextView.placeholder = NSLocalizedString(@"Beginner quantity", nil);
            instructionCell.beginnerQuantityTextView.font = styleManager.smallFont;
            instructionCell.beginnerQuantityTextView.textColor = styleManager.themeTextColor;
            instructionCell.beginnerQuantityTextView.textAlignment = NSTextAlignmentCenter;
            instructionCell.beginnerQuantityTextView.text = instruction.beginnerQuantity;
            instructionCell.intermediateQuantityTextView.placeholder = NSLocalizedString(@"Intermediate quantity", nil);
            instructionCell.intermediateQuantityTextView.font = styleManager.smallFont;
            instructionCell.intermediateQuantityTextView.textColor = styleManager.themeTextColor;
            instructionCell.intermediateQuantityTextView.textAlignment = NSTextAlignmentCenter;
            instructionCell.intermediateQuantityTextView.text = instruction.intermediateQuantity;
            instructionCell.advancedQuantityTextView.placeholder = NSLocalizedString(@"Advanced quantity", nil);
            instructionCell.advancedQuantityTextView.font = styleManager.smallFont;
            instructionCell.advancedQuantityTextView.textColor = styleManager.themeTextColor;
            instructionCell.advancedQuantityTextView.textAlignment = NSTextAlignmentCenter;
            instructionCell.advancedQuantityTextView.text = instruction.advancedQuantity;
            [instructionCell.upButton setImage:[UIImage tintableImageNamed:@"upIcon"] forState:UIControlStateNormal];
            instructionCell.upButton.tintColor = styleManager.themeTextColor;
            [instructionCell.upButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateNormal];
            [instructionCell.upButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateHighlighted];
            instructionCell.upButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            [instructionCell.downButton setImage:[UIImage tintableImageNamed:@"downIcon"] forState:UIControlStateNormal];
            instructionCell.downButton.tintColor = styleManager.themeTextColor;
            [instructionCell.downButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateNormal];
            [instructionCell.downButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateHighlighted];
            instructionCell.downButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            [instructionCell.trashButton setImage:[UIImage tintableImageNamed:@"trashIcon"] forState:UIControlStateNormal];
            instructionCell.trashButton.tintColor = styleManager.themeTextColor;
            [instructionCell.trashButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateNormal];
            [instructionCell.trashButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateHighlighted];
            instructionCell.trashButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            instructionCell.topBorder.backgroundColor = styleManager.themeTextColor;
            if (([self.exerciseInstructions count]-1) == indexPath.item) {
                instructionCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            } else {
                instructionCell.bottomBorder.backgroundColor = [UIColor clearColor];
            }
            cell = instructionCell;
            break;
        }
        case kSectionCreate: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.text = NSLocalizedString(@"Create Class", nil);
            labelCell.textLabel.textColor = styleManager.tintBlueColor;
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        default:
            break;
    }
    
    if ([cell isKindOfClass:[RJLabelCell class]] && (indexPath.section != kSectionCreate) && (indexPath.section != kSectionAddInstruction)) {
        RJLabelCell *labelCell = (RJLabelCell *)cell;
        labelCell.textLabel.font = styleManager.smallFont;
        labelCell.textLabel.textColor = styleManager.themeTextColor;
        labelCell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    cell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
    
    return cell;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Section createSection = indexPath.section;
    switch (createSection) {
        case kSectionName:
            break;
        case kSectionCategory:
            [[self navigationController] pushViewController:self.categoryViewController animated:YES];
            break;
        case kSectionAddInstruction: {
            RJParseExerciseInstruction *newInstruction = [RJParseExerciseInstruction object];
            [self.exerciseInstructions addObject:newInstruction];
            NSUInteger newIndex = [self.exerciseInstructions indexOfObject:newInstruction];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:kSectionInstructions]]];
            break;
        }
        case kSectionInstructions:
            break;
        case kSectionCreate: {
            RJParseCategory *category = (RJParseCategory *)self.categoryViewController.selectedObject;
            BOOL validates = (self.name && category && ([self.exerciseInstructions count] > 0));
            for (RJParseExerciseInstruction *instruction in self.exerciseInstructions) {
                if (!instruction.exercise || !instruction.advancedQuantity || !instruction.intermediateQuantity || !instruction.beginnerQuantity) {
                    validates = NO;
                    break;
                }
            }
            
            if (validates) {
                [SVProgressHUD show];
                [RJParseUtils createClassWithName:self.name classType:kRJParseClassTypeSelfPaced category:category instructor:nil tracks:nil exerciseInstructions:self.exerciseInstructions completion:^(BOOL success) {
                    if (success) {
                        self.name = nil;
                        _categoryViewController = nil;
                        _exerciseInstructions = [[NSMutableArray alloc] initWithObjects:[RJParseExerciseInstruction object], nil];
                        [self.collectionView reloadData];
                        [SVProgressHUD showSuccessWithStatus:nil];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error. Try again!", nil)];
                    }
                }];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Missing info", nil)];
            }
            break;
        }
        default:
            break;
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - Private Protocols - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat topInset = (section == kSectionInstructions) ? 0.0f : 30.0f;
    CGFloat bottomInset = (section == kSectionAddInstruction) ? 0.0f : 10.0f;
    return UIEdgeInsetsMake(topInset, 0.0f, bottomInset, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = (indexPath.section == kSectionInstructions) ? kCreateExerciseInstructionCellHeight : kLabelCellHeight;
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), height);
}

#pragma mark - Private Protocols - RJCreateSelfPacedExerciseInstructionCellDelegate

- (void)createSelfPacedExerciseInstructionCellAdvancedQuantityTextViewDidChange:(RJCreateSelfPacedExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.exerciseInstruction];
    RJParseExerciseInstruction *exerciseInstruction = self.exerciseInstructions[index];
    exerciseInstruction.advancedQuantity = cell.advancedQuantityTextView.text;
}

- (void)createSelfPacedExerciseInstructionCellBeginnerQuantityTextViewDidChange:(RJCreateSelfPacedExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.exerciseInstruction];
    RJParseExerciseInstruction *exerciseInstruction = self.exerciseInstructions[index];
    exerciseInstruction.beginnerQuantity = cell.beginnerQuantityTextView.text;
}

- (void)createSelfPacedExerciseInstructionCellIntermediateQuantityTextViewDidChange:(RJCreateSelfPacedExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.exerciseInstruction];
    RJParseExerciseInstruction *exerciseInstruction = self.exerciseInstructions[index];
    exerciseInstruction.intermediateQuantity = cell.intermediateQuantityTextView.text;
}

- (void)createSelfPacedExerciseInstructionCellDownButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.exerciseInstruction];
    if (index != ([self.exerciseInstructions count] - 1)) {
        [self.exerciseInstructions exchangeObjectAtIndex:index withObjectAtIndex:(index+1)];
        NSIndexPath *initialIndexPath = [NSIndexPath indexPathForItem:index inSection:kSectionInstructions];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(index+1) inSection:kSectionInstructions];
        [self.collectionView moveItemAtIndexPath:initialIndexPath toIndexPath:newIndexPath];
    }
}

- (void)createSelfPacedExerciseInstructionCellExerciseButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell {
    RJSingleSelectionViewController *exerciseViewController = [[RJSingleSelectionViewController alloc] init];
    exerciseViewController.view.tag = [self.exerciseInstructions indexOfObject:cell.exerciseInstruction];
    exerciseViewController.dataSource = self;
    exerciseViewController.delegate = self;
    exerciseViewController.navigationItem.title = [NSLocalizedString(@"Pick Exercise", nil) uppercaseString];
    if (self.exercises) {
        exerciseViewController.objects = self.exercises;
    } else {
        [RJParseUtils fetchAllExercisesWithCompletion:^(NSArray *exercises) {
            exerciseViewController.objects = exercises;
        }];
    }
    [[self navigationController] pushViewController:exerciseViewController animated:YES];
}

- (void)createSelfPacedExerciseInstructionCellUpButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.exerciseInstruction];
    if (index != 0) {
        [self.exerciseInstructions exchangeObjectAtIndex:index withObjectAtIndex:(index-1)];
        NSIndexPath *initialIndexPath = [NSIndexPath indexPathForItem:index inSection:kSectionInstructions];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(index-1) inSection:kSectionInstructions];
        [self.collectionView moveItemAtIndexPath:initialIndexPath toIndexPath:newIndexPath];
    }
}

- (void)createSelfPacedExerciseInstructionCellTrashButtonPressed:(RJCreateSelfPacedExerciseInstructionCell *)cell {
    if ([self.exerciseInstructions count] > 1) {
        NSUInteger index = [self.exerciseInstructions indexOfObject:cell.exerciseInstruction];
        [self.exerciseInstructions removeObjectAtIndex:index];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:kSectionInstructions]]];
    }
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _exerciseInstructions = [[NSMutableArray alloc] initWithObjects:[RJParseExerciseInstruction object], nil];
        [RJParseUtils fetchAllExercisesWithCompletion:^(NSArray *exercises) {
            if (exercises) {
                _exercises = exercises;
            }
        }];
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 44.0f, 0.0f);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, insets)) {
        self.collectionView.contentInset = insets;
        self.collectionView.scrollIndicatorInsets = insets;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSLocalizedString(@"Create Self-Paced Workout", nil) uppercaseString];
    
    [self.collectionView registerClass:[RJLabelCell class] forCellWithReuseIdentifier:kLabelCellID];
    [self.collectionView registerClass:[RJCreateSelfPacedExerciseInstructionCell class] forCellWithReuseIdentifier:kCreateExerciseInstructionCellID];
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
}

@end
