//
//  RJSinglePFObjectSelectionViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseUtils.h"
#import "RJSinglePFObjectSelectionViewController.h"
#import "RJStyleManager.h"
#import "RJSubtitleTableViewCell.h"

static NSString *const kSingleSelectionViewControllerCellID = @"SingleSelectionViewControllerCellID";


@interface RJSinglePFObjectSelectionViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedSearchResultsIndexPath;
@property (nonatomic, strong) PFObject *objectToSelect;

@property (nonatomic, assign, getter=isSearching) BOOL searching;

@property (nonatomic, strong) NSArray *searchResults;

@end


@implementation RJSinglePFObjectSelectionViewController

#pragma mark - Public Properties

- (PFObject *)selectedObject {
    if (self.objects && self.selectedIndexPath) {
        return [self.objects objectAtIndex:self.selectedIndexPath.row];
    } else {
        return nil;
    }
}

- (void)setSelectedObject:(PFObject *)selectedObject {
    _objectToSelect = selectedObject;
    if (self.objects) {
        [self selectObjectToSelectIfNecessary];
    }
}

- (void)setObjects:(NSArray *)objects {
    _objects = objects;
    _selectedIndexPath = nil;
    [self selectObjectToSelectIfNecessary];
    [self.tableView reloadData];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    _selectedIndexPath = selectedIndexPath;
    _selectedSearchResultsIndexPath = [self searchResultsIndexPathForIndexPath:_selectedIndexPath];
}

- (void)setSelectedSearchResultsIndexPath:(NSIndexPath *)selectedSearchResultsIndexPath {
    _selectedSearchResultsIndexPath = selectedSearchResultsIndexPath;
    _selectedIndexPath = [self indexPathForSearchResultsIndexPath:_selectedSearchResultsIndexPath];
}

- (void)setSearchResults:(NSArray *)searchResults {
    _searchResults = searchResults;
    _selectedSearchResultsIndexPath = [self searchResultsIndexPathForIndexPath:self.selectedIndexPath];
}

#pragma mark - Private Protocols - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([self.dataSource respondsToSelector:@selector(singleSelectionViewController:resultsForSearchString:objects:)] && (searchText.length > 0)) {
        self.searchResults = [self.dataSource singleSelectionViewController:self resultsForSearchString:searchText objects:self.objects];
    }
    [self.tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.searching = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    self.searching = NO;
    return YES;
}

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self useSearchResults]) {
        return [self.searchResults count];
    } else {
        return [self.objects count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleSelectionViewControllerCellID forIndexPath:indexPath];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    NSArray *objects = [self useSearchResults] ? self.searchResults : self.objects;
    
    cell.textLabel.text = [self.dataSource singleSelectionViewController:self titleForObject:objects[indexPath.row]];
    cell.textLabel.textColor = styleManager.themeTextColor;
    cell.textLabel.font = styleManager.smallBoldFont;
    
    if ([self.dataSource respondsToSelector:@selector(singleSelectionViewController:subtitleForObject:)]) {
        cell.detailTextLabel.text = [self.dataSource singleSelectionViewController:self subtitleForObject:objects[indexPath.row]];
        cell.detailTextLabel.textColor = styleManager.themeTextColor;
        cell.detailTextLabel.font = styleManager.smallFont;
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    NSIndexPath *selectedIndexPath = [self useSearchResults] ? self.selectedSearchResultsIndexPath : self.selectedIndexPath;
    if ([selectedIndexPath isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Public Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    UITableViewCell *previouslySelectedCell = nil;
    if ([self useSearchResults]) {
        previouslySelectedCell = [tableView cellForRowAtIndexPath:self.selectedSearchResultsIndexPath];
        self.selectedSearchResultsIndexPath = indexPath;
    } else {
        previouslySelectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        self.selectedIndexPath = indexPath;
    }
    previouslySelectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([self.delegate respondsToSelector:@selector(singleSelectionViewController:didSelectObject:)]) {
        [self.delegate singleSelectionViewController:self didSelectObject:self.objects[self.selectedIndexPath.row]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Private Instance Methods

- (BOOL)useSearchResults {
    return ((self.searchBar.text.length > 0) && self.isIncrementalSearchEnabled);
}

- (void)selectObjectToSelectIfNecessary {
    if (self.objectToSelect && self.objects) {
        NSInteger numberOfObjects = [self.objects count];
        for (NSInteger i = 0; i < numberOfObjects; i++) {
            PFObject *object = self.objects[i];
            if ([object.objectId isEqualToString:self.objectToSelect.objectId]) {
                self.selectedIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.tableView reloadData];
                self.objectToSelect = nil;
                
                if ([self.delegate respondsToSelector:@selector(singleSelectionViewController:didSelectObject:)]) {
                    [self.delegate singleSelectionViewController:self didSelectObject:self.objects[self.selectedIndexPath.row]];
                }
                break;
            }
        }
    }
}

- (NSIndexPath *)searchResultsIndexPathForIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath || !self.searchResults || !self.objects) { return nil; }
    
    PFObject *object = self.objects[indexPath.row];
    NSInteger rowForSearchResultsIndexPath = [self.searchResults indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [object.objectId isEqualToString:[obj objectId]];
    }];
    if (rowForSearchResultsIndexPath != NSNotFound) {
        return [NSIndexPath indexPathForRow:rowForSearchResultsIndexPath inSection:0];
    } else {
        return nil;
    }
}

- (NSIndexPath *)indexPathForSearchResultsIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath || !self.searchResults || !self.objects) { return nil; }
    
    PFObject *object = self.searchResults[indexPath.row];
    NSInteger rowForIndexPath = [self.objects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [object.objectId isEqualToString:[obj objectId]];
    }];
    if (rowForIndexPath != NSNotFound) {
        return [NSIndexPath indexPathForRow:rowForIndexPath inSection:0];
    } else {
        return nil;
    }
}

#pragma mark - Public Instance Methods

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.isSearching) {
        UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 44.0f, 0.0f);
        if (!UIEdgeInsetsEqualToEdgeInsets(self.tableView.contentInset, insets)) {
            self.tableView.contentInset = insets;
            self.tableView.scrollIndicatorInsets = insets;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.tintColor = styleManager.tintBlueColor;
    _searchBar.barStyle = UIBarStyleBlack;
    _searchBar.showsCancelButton = NO;
    self.navigationItem.titleView = self.searchBar;
    
    [self.tableView registerClass:[RJSubtitleTableViewCell class] forCellReuseIdentifier:kSingleSelectionViewControllerCellID];
    self.tableView.backgroundColor = styleManager.themeBackgroundColor;
    self.tableView.separatorColor = styleManager.themeTextColor;
}

@end
