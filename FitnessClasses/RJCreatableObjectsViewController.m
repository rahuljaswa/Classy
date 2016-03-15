//
//  RJCreatableObjectsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/31/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreatableObjectsViewController.h"
#import "RJCreateCategoryViewController.h"
#import "RJCreateEditChoreographedClassViewController.h"
#import "RJCreateEditSelfPacedClassViewController.h"
#import "RJCreateExerciseViewController.h"
#import "RJCreateInstructorViewController.h"
#import "RJStyleManager.h"

static NSString *const kCellID = @"CellID";

typedef NS_ENUM(NSInteger, Row) {
    kRowExercise,
    kRowInstructor,
    kRowCategory,
    kRowClassSelfPaced,
    kRowClassChoreographed,
    kNumRows
};


@implementation RJCreatableObjectsViewController

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    
    Row creatableObjectsRow = indexPath.row;
    switch (creatableObjectsRow) {
        case kRowCategory:
            cell.textLabel.text = NSLocalizedString(@"Create Category", nil);
            break;
        case kRowClassChoreographed:
            cell.textLabel.text = NSLocalizedString(@"Create Choreographed Class", nil);
            break;
        case kRowClassSelfPaced:
            cell.textLabel.text = NSLocalizedString(@"Create Self-Paced Class", nil);
            break;
        case kRowExercise:
            cell.textLabel.text = NSLocalizedString(@"Create Exercise", nil);
            break;
        case kRowInstructor:
            cell.textLabel.text = NSLocalizedString(@"Create Instructor", nil);
            break;
        default:
            break;
    }
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor = styleManager.themeTextColor;
    cell.textLabel.textColor = styleManager.themeTextColor;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Private Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewControllerToPush = nil;
    Row creatableObjectsRow = indexPath.row;
    switch (creatableObjectsRow) {
        case kRowCategory:
            viewControllerToPush = [[RJCreateCategoryViewController alloc] init];
            break;
        case kRowClassChoreographed:
            viewControllerToPush = [[RJCreateEditChoreographedClassViewController alloc] init];
            break;
        case kRowClassSelfPaced:
            viewControllerToPush = [[RJCreateEditSelfPacedClassViewController alloc] init];
            break;
        case kRowExercise:
            viewControllerToPush = [[RJCreateExerciseViewController alloc] init];
            break;
        case kRowInstructor:
            viewControllerToPush = [[RJCreateInstructorViewController alloc] init];
            break;
        default:
            break;
    }
    [[self navigationController] pushViewController:viewControllerToPush animated:YES];
}

#pragma mark - Private Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSLocalizedString(@"Create", nil) uppercaseString];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    self.tableView.separatorColor = styleManager.themeTextColor;
    self.tableView.backgroundColor = styleManager.themeBackgroundColor;
}

@end
