//
//  RJCreateEditExerciseViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateEditExerciseViewController.h"
#import "RJLabelCell.h"
#import "RJMusclesViewController.h"
#import "RJParseExerciseEquipment.h"
#import "RJParseUtils.h"
#import "RJSinglePFObjectSelectionViewController.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"
#import <SZTextView/SZTextView.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kLabelCellID = @"LabelCellID";
static const CGFloat kCellHeight = 44.0f;

typedef NS_ENUM(NSInteger, Section) {
    kSectionName,
    kSectionPrimaryEquipment,
    kSectionMuscles,
    kSectionCreate,
    kNumSections
};

typedef NS_ENUM(NSInteger, MusclesSectionItem) {
    kMusclesSectionItemPrimary,
    kMusclesSectionItemSecondary,
    kNumMusclesSectionItems
};


@interface RJCreateEditExerciseViewController () <RJSingleSelectionViewControllerDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong, readonly) RJSinglePFObjectSelectionViewController *equipmentViewController;
@property (nonatomic, strong, readonly) RJMusclesViewController *primaryMusclesViewController;
@property (nonatomic, strong, readonly) RJMusclesViewController *secondaryMusclesViewController;

@end


@implementation RJCreateEditExerciseViewController

@synthesize equipmentViewController = _equipmentViewController;
@synthesize primaryMusclesViewController = _primaryMusclesViewController;
@synthesize secondaryMusclesViewController = _secondaryMusclesViewController;

#pragma mark - Private Properties

- (RJSinglePFObjectSelectionViewController *)equipmentViewController {
    if (!_equipmentViewController) {
        _equipmentViewController = [[RJSinglePFObjectSelectionViewController alloc] init];
        _equipmentViewController.navigationItem.title = [NSLocalizedString(@"Pick Equipment", nil) uppercaseString];
        _equipmentViewController.dataSource = self;
        [RJParseUtils fetchAllEquipmentWithCompletion:^(NSArray *equipment) {
            _equipmentViewController.objects = equipment;
        }];
    }
    return _equipmentViewController;
}

- (RJMusclesViewController *)primaryMusclesViewController {
    if (!_primaryMusclesViewController) {
        _primaryMusclesViewController = [[RJMusclesViewController alloc] init];
    }
    return _primaryMusclesViewController;
}

- (RJMusclesViewController *)secondaryMusclesViewController {
    if (!_secondaryMusclesViewController) {
        _secondaryMusclesViewController = [[RJMusclesViewController alloc] init];
    }
    return _secondaryMusclesViewController;
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController titleForObject:(NSObject *)object {
    RJParseExerciseEquipment *equipment = (RJParseExerciseEquipment *)object;
    return equipment.name;
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
    
    Section createExerciseSection = section;
    switch (createExerciseSection) {
        case kSectionName:
            numberOfItems = 1;
            break;
        case kSectionPrimaryEquipment:
            numberOfItems = 1;
            break;
        case kSectionMuscles:
            numberOfItems = kNumMusclesSectionItems;
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
    RJLabelCell *cell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    cell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
    
    cell.textLabel.font = styleManager.smallFont;
    cell.textLabel.textColor = styleManager.themeTextColor;
    
    cell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    
    Section createExerciseSection = indexPath.section;
    switch (createExerciseSection) {
        case kSectionName:
            cell.style = kRJLabelCellStyleTextField;
            cell.textField.delegate = self;
            cell.textField.placeholder = NSLocalizedString(@"Name", nil);
            cell.textField.font = styleManager.smallFont;
            cell.textField.textColor = styleManager.themeTextColor;
            cell.textField.text = self.name;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.accessoryView.image = nil;
            cell.topBorder.backgroundColor = styleManager.themeTextColor;
            cell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            break;
        case kSectionPrimaryEquipment:
            cell.style = kRJLabelCellStyleTextLabel;
            cell.textLabel.text = NSLocalizedString(@"Equipment", nil);
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.accessoryView.image = [UIImage imageNamed:@"forwardIcon"];
            cell.topBorder.backgroundColor = styleManager.themeTextColor;
            cell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            break;
        case kSectionMuscles: {
            cell.style = kRJLabelCellStyleTextLabel;
            cell.accessoryView.image = [UIImage imageNamed:@"forwardIcon"];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            
            MusclesSectionItem musclesSectionItem = indexPath.item;
            switch (musclesSectionItem) {
                case kMusclesSectionItemPrimary:
                    cell.textLabel.text = NSLocalizedString(@"Primary Muscles", nil);
                    cell.topBorder.backgroundColor = styleManager.themeTextColor;
                    cell.bottomBorder.backgroundColor = styleManager.themeTextColor;
                    break;
                case kMusclesSectionItemSecondary:
                    cell.textLabel.text = NSLocalizedString(@"Secondary Muscles", nil);
                    cell.topBorder.backgroundColor = [UIColor clearColor];
                    cell.bottomBorder.backgroundColor = styleManager.themeTextColor;
                    break;
                default:
                    break;
            }
            
            cell.textLabel.textColor = styleManager.themeTextColor;
            break;
        }
        case kSectionCreate: {
            cell.style = kRJLabelCellStyleTextLabel;
            cell.accessoryView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"Create Exercise", nil);
            cell.textLabel.textColor = styleManager.tintBlueColor;
            cell.textLabel.font = styleManager.smallBoldFont;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.topBorder.backgroundColor = styleManager.themeTextColor;
            cell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Section createExerciseSection = indexPath.section;
    switch (createExerciseSection) {
        case kSectionName:
            break;
        case kSectionPrimaryEquipment:
            [[self navigationController] pushViewController:self.equipmentViewController animated:YES];
            break;
        case kSectionMuscles: {
            MusclesSectionItem musclesSectionItem = indexPath.item;
            switch (musclesSectionItem) {
                case kMusclesSectionItemPrimary:
                    [[self navigationController] pushViewController:self.primaryMusclesViewController animated:YES];
                    break;
                case kMusclesSectionItemSecondary:
                    [[self navigationController] pushViewController:self.secondaryMusclesViewController animated:YES];
                    break;
                default:
                    break;
            }
            break;
        }
        case kSectionCreate: {
            RJParseExerciseEquipment *equipment = (RJParseExerciseEquipment *)self.equipmentViewController.selectedObject;
            if (self.name && equipment && ([self.primaryMusclesViewController.selectedMuscles count] > 0)) {
                [SVProgressHUD show];
                [RJParseUtils createExerciseWithName:self.name primaryEquipment:equipment primaryMuscles:self.primaryMusclesViewController.selectedMuscles secondaryMuscles:self.secondaryMusclesViewController.selectedMuscles completion:^(BOOL success) {
                    if (success) {
                        self.name = nil;
                        _primaryMusclesViewController = nil;
                        _secondaryMusclesViewController = nil;
                        _equipmentViewController = nil;
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
    if (collectionView == self.collectionView) {
        return UIEdgeInsetsMake(30.0f, 0.0f, 10.0f, 0.0f);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), kCellHeight);
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    return [super initWithCollectionViewLayout:layout];
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
    
    self.navigationItem.title = [NSLocalizedString(@"Create Exercise", nil) uppercaseString];
    
    [self.collectionView registerClass:[RJLabelCell class] forCellWithReuseIdentifier:kLabelCellID];
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
}

@end
