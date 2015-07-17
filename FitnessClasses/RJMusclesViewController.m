//
//  RJMusclesViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJMusclesViewController.h"
#import "RJParseMuscle.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"

static NSString *const kMusclesViewControllerCellID = @"MusclesViewControllerCellID";


@interface RJMusclesViewController ()

@property (nonatomic, strong) NSArray *muscles;
@property (nonatomic, strong, readonly) NSMutableIndexSet *selectedIndexes;

@end


@implementation RJMusclesViewController

#pragma mark - Public Properties

- (NSArray *)selectedMuscles {
    return [self.muscles objectsAtIndexes:self.selectedIndexes];
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.muscles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMusclesViewControllerCellID forIndexPath:indexPath];
    cell.contentView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    RJParseMuscle *muscle = self.muscles[indexPath.item];
    cell.textLabel.text = muscle.name;
    cell.textLabel.textColor = styleManager.themeTextColor;
    cell.textLabel.font = styleManager.smallBoldFont;
    
    if ([self.selectedIndexes containsIndex:indexPath.item]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Public Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.selectedIndexes containsIndex:indexPath.item]) {
        [self.selectedIndexes removeIndex:indexPath.item];
         cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.selectedIndexes addIndex:indexPath.item];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _selectedIndexes = [[NSMutableIndexSet alloc] init];
        [RJParseUtils fetchAllMusclesWithCompletion:^(NSArray *muscles) {
            self.muscles = muscles;
            [self.tableView reloadData];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSLocalizedString(@"Pick Muscles", nil) uppercaseString];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMusclesViewControllerCellID];
    self.tableView.backgroundColor = styleManager.themeBackgroundColor;
    self.tableView.separatorColor = styleManager.themeTextColor;
}

@end
