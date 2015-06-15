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
#import "RJParseCategory.h"
#import "RJParseClass.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"

typedef NS_ENUM(NSUInteger, ClassesState) {
    kClassesStateNone,
    kClassesStatePopular,
    kClassesStateNew,
    kClassesStateCategory
};


@interface RJHomeGalleryViewController ()

@property (nonatomic, strong) RJParseCategory *category;
@property (nonatomic, strong, readwrite) NSArray *classes;
@property (nonatomic, assign) ClassesState classesState;

@end


@implementation RJHomeGalleryViewController

#pragma mark - Private Properties

- (void)setClassesState:(ClassesState)classesState completion:(void (^)(void))completion {
    void (^fetchCompletion)(NSArray *) = ^ (NSArray *classes) {
        self.classes = classes;
        [self.collectionView reloadData];
        if (completion) {
            completion();
        }
    };
    
    switch (classesState) {
        case kClassesStateNone:
            break;
        case kClassesStateCategory:
            _classesState = classesState;
            [RJParseUtils fetchClassesForCategory:self.category completion:fetchCompletion];
            break;
        case kClassesStateNew:
            if (_classesState != classesState) {
                _classesState = classesState;
                [RJParseUtils fetchNewClassesWithCompletion:fetchCompletion];
            }
            break;
        case kClassesStatePopular:
            if (_classesState != classesState) {
                _classesState = classesState;
                [RJParseUtils fetchPopularClassesWithCompletion:fetchCompletion];
            }
            break;
    }
}

- (void)setClassesStateToClassesStateCategoryWithCategory:(RJParseCategory *)category completion:(void (^)(void))completion {
    if (!((self.classesState == kClassesStateCategory) && ([self.category isEqual:category]))) {
        self.category = category;
        [self setClassesState:kClassesStateCategory completion:completion];
    }
}

#pragma mark - Public Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.homeGalleryDelegate homeGalleryViewController:self wantsPlayForClass:self.classes[indexPath.item] autoPlay:YES];
}

#pragma mark - Public Protocols - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.classes count];
}

#pragma mark - Private Instance Methods

- (void)tapRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
    RJClassDetailsViewController *detailsViewController = [[RJClassDetailsViewController alloc] initWithNibName:nil bundle:nil];
    detailsViewController.klass = self.classes[tapGestureRecognizer.view.tag];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
}

#pragma mark - Public Instance Methods

- (void)configureCell:(RJGalleryCell *)galleryCell indexPath:(NSIndexPath *)indexPath {
    [super configureCell:galleryCell indexPath:indexPath];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    RJParseClass *class = self.classes[indexPath.item];
    
    galleryCell.title.font = styleManager.giantBoldFont;
    galleryCell.title.text = class.name;
    
    NSURL *url = [NSURL URLWithString:class.coverArtURL];
    if (url) {
        RJClassImageCacheEntity *entity = [[RJClassImageCacheEntity alloc] initWithClassImageURL:url objectID:class.objectId];
        [galleryCell updateWithImageEntity:entity formatName:kRJClassImageFormatCardSquare16BitBGR placeholder:nil];
    }
    
    RJGalleryCellAccessoriesView *accessoriesView = (RJGalleryCellAccessoriesView *)galleryCell.accessoriesView;
    if (!(accessoriesView && [accessoriesView isKindOfClass:[RJGalleryCellAccessoriesView class]])) {
        accessoriesView = [[RJGalleryCellAccessoriesView alloc] initWithFrame:galleryCell.contentView.bounds];
        galleryCell.accessoriesView = accessoriesView;
    }
    
    NSUInteger totalSeconds = [class.length unsignedIntegerValue];
    NSString *lengthString = [NSString hhmmaaForTotalSeconds:totalSeconds];
    NSString *summaryText = nil;
    if (class.instructor && class.category) {
        summaryText = [NSString stringWithFormat:@" %@ | %@ | %@ ", class.instructor.name, class.category.name, lengthString];
    } else if (class.instructor) {
        summaryText = [NSString stringWithFormat:@" %@ | %@ ", class.instructor.name, lengthString];
    } else if (class.category) {
        summaryText = [NSString stringWithFormat:@" %@ | %@ ", class.category.name, lengthString];
    } else {
        summaryText = [NSString stringWithFormat:@" %@ ", lengthString];
    }
    
    NSUInteger classCost = [class.creditsCost unsignedIntegerValue];
    NSString *classCostString = nil;
    if (classCost == 0) {
        classCostString = NSLocalizedString(@"| Free ", nil);
    } else if (classCost == 1) {
        classCostString = NSLocalizedString(@"| 1 Credit ", nil);
    } else {
        classCostString = [NSString stringWithFormat:NSLocalizedString(@"| %lu Credits ", nil), (unsigned long)classCost];
    }
    
    accessoriesView.summary.text = [summaryText stringByAppendingString:classCostString];;
    accessoriesView.summary.font = styleManager.smallFont;
    accessoriesView.summary.textColor = styleManager.lightTextColor;
    accessoriesView.summary.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    
    accessoriesView.playsCount.text = [NSString stringWithFormat:@" %lu", (unsigned long)[class.plays unsignedIntegerValue]];
    accessoriesView.playsCount.font = styleManager.smallFont;
    accessoriesView.playsCount.textColor = styleManager.lightTextColor;
    accessoriesView.playsCount.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    
    [accessoriesView.playsIcon setImage:[UIImage tintableImageNamed:@"playsIcon"]];
    accessoriesView.playsIcon.contentMode = UIViewContentModeCenter;
    [accessoriesView.playsIcon setTintColor:styleManager.lightTextColor];
    accessoriesView.playsIcon.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    accessoriesView.userInteractionEnabled = YES;
    accessoriesView.tag = indexPath.item;
    [accessoriesView addGestureRecognizer:tapRecognizer];
}

- (void)reloadWithCompletion:(void (^)(BOOL))completion {
    void (^fetchCompletion)(NSArray *) = ^(NSArray *classes) {
        self.classes = classes;
        [self.collectionView reloadData];
        if (completion) {
            completion(!!classes);
        }
    };
    
    switch (self.classesState) {
        case kClassesStateNone:
            break;
        case kClassesStateCategory:
            [RJParseUtils fetchClassesForCategory:self.category completion:fetchCompletion];
            break;
        case kClassesStateNew:
            [RJParseUtils fetchNewClassesWithCompletion:fetchCompletion];
            break;
        case kClassesStatePopular:
            [RJParseUtils fetchPopularClassesWithCompletion:fetchCompletion];
            break;
    }
}

- (void)switchToClassesForCategory:(RJParseCategory *)category completion:(void (^)(void))completion {
    [self setClassesStateToClassesStateCategoryWithCategory:category completion:completion];
}

- (void)switchToNewClassesWithCompletion:(void (^)(void))completion {
    [self setClassesState:kClassesStateNew completion:completion];
}

- (void)switchToPopularClassesWithCompletion:(void (^)(void))completion {
    [self setClassesState:kClassesStatePopular completion:completion];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 40.0f, 0.0f);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, insets)) {
        self.collectionView.contentInset = insets;
        self.collectionView.scrollIndicatorInsets = insets;
    }
}

@end
