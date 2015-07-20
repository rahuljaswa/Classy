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
#import "RJSubtitleTableViewCell.h"

static NSString *const kSingleSelectionViewControllerCellID = @"SingleSelectionViewControllerCellID";


@interface RJSingleSelectionViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end


@implementation RJSingleSelectionViewController

#pragma mark - Public Properties

- (NSObject *)selectedObject {
    if (self.objects && self.selectedIndexPath) {
        return [self.objects objectAtIndex:self.selectedIndexPath.row];
    } else {
        return nil;
    }
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
    RJSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleSelectionViewControllerCellID forIndexPath:indexPath];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    cell.textLabel.text = [self.dataSource singleSelectionViewController:self titleForObject:self.objects[indexPath.item]];
    cell.textLabel.textColor = styleManager.themeTextColor;
    cell.textLabel.font = styleManager.smallBoldFont;
    
    if ([self.dataSource respondsToSelector:@selector(singleSelectionViewController:subtitleForObject:)]) {
        cell.detailTextLabel.text = [self.dataSource singleSelectionViewController:self subtitleForObject:self.objects[indexPath.item]];
        cell.detailTextLabel.textColor = styleManager.themeTextColor;
        cell.detailTextLabel.font = styleManager.smallFont;
    } else {
        cell.detailTextLabel.text = nil;
    }
    
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 44.0f, 0.0f);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.tableView.contentInset, insets)) {
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    [self.tableView registerClass:[RJSubtitleTableViewCell class] forCellReuseIdentifier:kSingleSelectionViewControllerCellID];
    self.tableView.backgroundColor = styleManager.themeBackgroundColor;
    self.tableView.separatorColor = styleManager.themeTextColor;
}

@end
