//
//  RJCategorySelectorViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/31/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCategorySelectorViewController.h"
#import "RJCreateCategoryViewController.h"
#import "RJParseCategory.h"
#import "RJParseUtils.h"


@interface RJCategorySelectorViewController () <RJCreateCategoryViewControllerDelegate, RJSingleSelectionViewControllerDataSource>

@end


@implementation RJCategorySelectorViewController

#pragma mark - Private Protocols - RJCreateCategoryViewControllerDelegate

- (void)createCategoryViewControllerDidCreateCategory:(RJCreateCategoryViewController *)createCategoryViewController {
    [self refetchAndReloadData];
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController titleForObject:(NSObject *)object {
    RJParseCategory *category = (RJParseCategory *)object;
    return category.name;
}

- (NSArray *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController resultsForSearchString:(NSString *)searchString objects:(NSArray *)objects {
    NSIndexSet *matchingIndexes = [objects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RJParseCategory *category = obj;
        return ([category.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound);
    }];
    return [objects objectsAtIndexes:matchingIndexes];
}

#pragma mark - Private Instance Methods

- (void)addButtonPressed:(UIBarButtonItem *)barButtonItem {
    RJCreateCategoryViewController *createCategoryViewController = [[RJCreateCategoryViewController alloc] init];
    createCategoryViewController.createDelegate = self;
    [[self navigationController] pushViewController:createCategoryViewController animated:YES];
}

- (void)refetchAndReloadData {
    [RJParseUtils fetchAllCategoriesWithCompletion:^(NSArray *categories) {
        self.objects = categories;
        [self.tableView reloadData];
    }];
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    [self refetchAndReloadData];
}

@end
