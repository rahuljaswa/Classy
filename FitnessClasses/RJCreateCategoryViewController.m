//
//  RJCreateCategoryViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/31/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateCategoryViewController.h"
#import "RJInsetLabel.h"
#import "RJLabelCell.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"
#import <SZTextView/SZTextView.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kLabelCellID = @"LabelCellID";
static const CGFloat kCellHeight = 44.0f;


typedef NS_ENUM(NSInteger, Section) {
    kSectionName,
    kSectionCreate,
    kNumSections
};


@interface RJCreateCategoryViewController () <UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic, strong) NSString *name;

@end


@implementation RJCreateCategoryViewController

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark - Private Protocols - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(30.0f, 0.0f, 10.0f, 0.0f);
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    Section createCategorySection = section;
    switch (createCategorySection) {
        case kSectionName:
            numberOfItems = 1;
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
    
    Section createCategorySection = indexPath.section;
    switch (createCategorySection) {
        case kSectionName: {
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
        }
        case kSectionCreate: {
            cell.style = kRJLabelCellStyleTextLabel;
            cell.textLabel.insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
            cell.accessoryView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"Create Category", nil);
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
    Section createCategorySection = indexPath.section;
    switch (createCategorySection) {
        case kSectionName: {
            break;
        }
        case kSectionCreate: {
            if (self.name) {
                [SVProgressHUD show];
                [RJParseUtils createCategoryWithName:self.name completion:^(BOOL success) {
                    if (success) {
                        self.name = nil;
                        [self.collectionView reloadData];
                        [SVProgressHUD showSuccessWithStatus:nil];
                        if ([self.createDelegate respondsToSelector:@selector(createCategoryViewControllerDidCreateCategory:)]) {
                            [self.createDelegate createCategoryViewControllerDidCreateCategory:self];
                        }
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
    
    self.navigationItem.title = [NSLocalizedString(@"Create Category", nil) uppercaseString];
    
    [self.collectionView registerClass:[RJLabelCell class] forCellWithReuseIdentifier:kLabelCellID];
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
}

@end
