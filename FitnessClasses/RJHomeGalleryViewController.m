//
//  RJHomeGalleryViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJClassDetailsViewController.h"
#import "RJClassImageCacheEntity.h"
#import "RJGalleryCell.h"
#import "RJGalleryCell+FastImageCache.h"
#import "RJGalleryCellAccessoriesView.h"
#import "RJHomeGalleryViewController.h"
#import "RJInsetLabel.h"
#import "RJLabelCell.h"
#import "RJParseCategory.h"
#import "RJParseClass.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"

static NSString *const kGalleryCellID = @"GalleryCellID";
static NSString *const kLabelCellID = @"LabelCellID";


@interface RJHomeGalleryViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign, getter=hasFoundInitialClass) BOOL foundInitialClass;
@property (nonatomic, strong) RJParseCategory *category;
@property (nonatomic, strong, readwrite) NSArray *classes;

@end


@implementation RJHomeGalleryViewController

#pragma mark - Private Properties

- (void)setCategory:(RJParseCategory *)category completion:(void (^)(void))completion {
    self.category = category;
    [RJParseUtils fetchClassesForCategory:self.category completion:^(NSArray *classes) {
        self.classes = classes;
        [self.collectionView reloadData];
        
        if (!self.hasFoundInitialClass) {
            NSUInteger firstFreeClassIndex = [classes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return ([[(RJParseClass *)obj creditsCost] unsignedIntegerValue] == 0);
            }];
            
            if (firstFreeClassIndex != NSNotFound) {
                [self.homeGalleryDelegate homeGalleryViewController:self wantsPlayForClass:self.classes[firstFreeClassIndex] autoPlay:NO];
            }
            
            self.foundInitialClass = YES;
        }
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Public Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self.homeGalleryDelegate homeGalleryViewController:self wantsPlayForClass:self.classes[indexPath.item] autoPlay:YES];
    }
}

#pragma mark - Public Protocols - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0f, 0.0f, 1.0f, 0.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static RJLabelCell *sizingLabelCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingLabelCell = [[RJLabelCell alloc] initWithFrame:CGRectZero];
        });
        [self configureLabelCell:sizingLabelCell];
        CGFloat height = [sizingLabelCell.textLabel sizeThatFits:CGSizeMake(CGRectGetWidth(collectionView.bounds), CGFLOAT_MAX)].height;
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), height);
    } else {
        CGFloat width = CGRectGetWidth(collectionView.bounds);
        CGFloat height = width;
        return CGSizeMake(MIN(CGRectGetWidth(collectionView.bounds), width), MIN(CGRectGetHeight(collectionView.bounds), height));
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

#pragma mark - Public Protocols - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return !!self.category.categoryDescription;
    } else {
        return [self.classes count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        RJLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
        [self configureLabelCell:cell];
        return cell;
    } else {
        RJGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGalleryCellID forIndexPath:indexPath];
        
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        
        cell.disableDuringLoading = NO;
        cell.mask = YES;
        cell.backgroundView.backgroundColor = [UIColor lightGrayColor];
        
        RJParseClass *klass = self.classes[indexPath.item];
        
        cell.title.font = styleManager.giantBoldFont;
        cell.title.text = klass.name;
        
        NSURL *url = [NSURL URLWithString:klass.coverArtURL];
        if (url) {
            RJClassImageCacheEntity *entity = [[RJClassImageCacheEntity alloc] initWithClassImageURL:url objectID:klass.objectId];
            [cell updateWithImageEntity:entity formatName:kRJClassImageFormatCardSquare16BitBGR placeholder:nil];
        }
        
        RJGalleryCellAccessoriesView *accessoriesView = (RJGalleryCellAccessoriesView *)cell.accessoriesView;
        if (!(accessoriesView && [accessoriesView isKindOfClass:[RJGalleryCellAccessoriesView class]])) {
            accessoriesView = [[RJGalleryCellAccessoriesView alloc] initWithFrame:cell.contentView.bounds];
            cell.accessoriesView = accessoriesView;
        }
        
        NSString *summaryText = nil;
        if (klass.instructor && klass.category) {
            summaryText = [NSString stringWithFormat:@" %@ | %@ ", klass.instructor.name, klass.category.name];
        } else if (klass.instructor) {
            summaryText = [NSString stringWithFormat:@" %@ ", klass.instructor.name];
        } else if (klass.category) {
            summaryText = [NSString stringWithFormat:@" %@ ", klass.category.name];
        }
        
        NSUInteger totalSeconds = klass.length;
        if (klass.length > 0) {
            NSString *lengthString = [NSString hhmmaaForTotalSeconds:totalSeconds];
            summaryText = [summaryText stringByAppendingString:[NSString stringWithFormat:@"| %@ ", lengthString]];
        }
        
        NSUInteger classCost = [klass.creditsCost unsignedIntegerValue];
        NSString *classCostString = nil;
        if (classCost == 0) {
            classCostString = NSLocalizedString(@"| Free ", nil);
        } else if (classCost == 1) {
            classCostString = NSLocalizedString(@"| 1 Credit ", nil);
        } else {
            classCostString = [NSString stringWithFormat:NSLocalizedString(@"| %lu Credits ", nil), (unsigned long)classCost];
        }
        
        accessoriesView.summary.text = [summaryText stringByAppendingString:classCostString];;
        accessoriesView.summary.font = styleManager.verySmallFont;
        accessoriesView.summary.textColor = cell.title.textColor;
        accessoriesView.summary.backgroundColor = styleManager.maskColor;
        
        accessoriesView.playsCount.text = [NSString stringWithFormat:@" %lu", (unsigned long)[klass.plays unsignedIntegerValue]];
        accessoriesView.playsCount.font = styleManager.verySmallFont;
        accessoriesView.playsCount.textColor = cell.title.textColor;
        accessoriesView.playsCount.backgroundColor = styleManager.maskColor;
        
        [accessoriesView.playsIcon setImage:[UIImage tintableImageNamed:@"playsIcon"]];
        accessoriesView.playsIcon.contentMode = UIViewContentModeCenter;
        [accessoriesView.playsIcon setTintColor:cell.title.textColor];
        accessoriesView.playsIcon.backgroundColor = styleManager.maskColor;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        accessoriesView.userInteractionEnabled = YES;
        accessoriesView.tag = indexPath.item;
        [accessoriesView addGestureRecognizer:tapRecognizer];
        
        return cell;
    }
}

#pragma mark - Private Instance Methods

- (void)configureLabelCell:(RJLabelCell *)labelCell {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    labelCell.style = kRJLabelCellStyleTextLabel;
    labelCell.textLabel.text = self.category.categoryDescription;
    labelCell.textLabel.font = styleManager.smallBoldFont;
    labelCell.textLabel.textColor = styleManager.themeTextColor;
    labelCell.textLabel.insets = UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f);
    labelCell.textLabel.numberOfLines = 0;
    labelCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    labelCell.backgroundView.backgroundColor = styleManager.tintLightGrayColor;
}

- (void)tapRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
    RJClassDetailsViewController *detailsViewController = [[RJClassDetailsViewController alloc] initWithNibName:nil bundle:nil];
    detailsViewController.klass = self.classes[tapGestureRecognizer.view.tag];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    return [super initWithCollectionViewLayout:layout];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    if (self.category) {
        [RJParseUtils fetchClassesForCategory:self.category completion:^(NSArray *classes) {
            self.classes = classes;
            [self.collectionView reloadData];
            if (completion) {
                completion(!!classes);
            }
        }];
    }
}

- (void)switchToClassesForCategory:(RJParseCategory *)category completion:(void (^)(void))completion {
    if (![self.category isEqual:category]) {
        [self setCategory:category completion:completion];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 40.0f, 0.0f);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, insets)) {
        self.collectionView.contentInset = insets;
        self.collectionView.scrollIndicatorInsets = insets;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[RJGalleryCell class] forCellWithReuseIdentifier:kGalleryCellID];
    [self.collectionView registerClass:[RJLabelCell class] forCellWithReuseIdentifier:kLabelCellID];
}

@end
