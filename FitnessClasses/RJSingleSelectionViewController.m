//
//  RJEquipmentViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJSingleSelectionViewController.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"

static NSString *const kSingleSelectionViewControllerCellID = @"SingleSelectionViewControllerCellID";


@interface RJSingleSelectionViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end


@implementation RJSingleSelectionViewController

#pragma mark - Public Properties

- (NSObject *)selectedObject {
    return [self.objects objectAtIndex:self.selectedIndexPath.row];
}

- (void)setObjects:(NSArray *)objects {
    _objects = objects;
    _selectedIndexPath = nil;
    [self.tableView reloadData];
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleSelectionViewControllerCellID forIndexPath:indexPath];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    cell.textLabel.text = [self.dataSource singleSelectionViewController:self titleForObject:self.objects[indexPath.item]];
    cell.textLabel.textColor = styleManager.themeTextColor;
    cell.textLabel.font = styleManager.smallBoldFont;
    
    if ([self.selectedIndexPath isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Public Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (![indexPath isEqual:self.selectedIndexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *previouslySelectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        previouslySelectedCell.accessoryType = UITableViewCellAccessoryNone;
        
        self.selectedIndexPath = indexPath;
        
        if ([self.delegate respondsToSelector:@selector(singleSelectionViewController:didSelectObject:)]) {
            [self.delegate singleSelectionViewController:self didSelectObject:self.objects[self.selectedIndexPath.item]];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Public Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSingleSelectionViewControllerCellID];
    self.tableView.backgroundColor = styleManager.themeBackgroundColor;
    self.tableView.separatorColor = styleManager.themeTextColor;
}

@end
