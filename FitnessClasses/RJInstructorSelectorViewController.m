//
//  RJInstructorSelectorViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/31/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreateInstructorViewController.h"
#import "RJInstructorSelectorViewController.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"


@interface RJInstructorSelectorViewController () <RJCreateInstructorViewControllerDelegate, RJSingleSelectionViewControllerDataSource>

@end


@implementation RJInstructorSelectorViewController

#pragma mark - Private Protocols - RJCreateInstructorViewControllerDelegate

- (void)createInstructorViewControllerDidCreateInstructor:(RJCreateInstructorViewController *)createInstructorViewController {
    [self refetchAndReloadData];
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController titleForObject:(NSObject *)object {
    RJParseUser *instructor = (RJParseUser *)object;
    return instructor.name;
}

- (NSArray *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController resultsForSearchString:(NSString *)searchString objects:(NSArray *)objects {
    NSIndexSet *matchingIndexes = [objects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RJParseUser *instructor = obj;
        return ([instructor.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound);
    }];
    return [objects objectsAtIndexes:matchingIndexes];
}

#pragma mark - Private Instance Methods

- (void)addButtonPressed:(UIBarButtonItem *)barButtonItem {
    RJCreateInstructorViewController *createInstructorViewController = [[RJCreateInstructorViewController alloc] init];
    createInstructorViewController.createDelegate = self;
    [[self navigationController] pushViewController:createInstructorViewController animated:YES];
}

- (void)refetchAndReloadData {
    [RJParseUtils fetchAllInstructorsWithCompletion:^(NSArray *instructors) {
        self.objects = instructors;
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
