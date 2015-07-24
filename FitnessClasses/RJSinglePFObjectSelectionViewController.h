//
//  RJSinglePFObjectSelectionViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJSinglePFObjectSelectionViewController;

@protocol RJSingleSelectionViewControllerDelegate <NSObject>

- (void)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController didSelectObject:(NSObject *)object;

@end


@class RJSinglePFObjectSelectionViewController;

@protocol RJSingleSelectionViewControllerDataSource <NSObject>

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController titleForObject:(NSObject *)object;

@optional

- (NSArray *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController resultsForSearchString:(NSString *)searchString objects:(NSArray *)objects;
- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController subtitleForObject:(NSObject *)object;

@end


@class PFObject;

@interface RJSinglePFObjectSelectionViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, weak) id<RJSingleSelectionViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<RJSingleSelectionViewControllerDelegate> delegate;

@property (nonatomic, strong) PFObject *selectedObject;
@property (nonatomic, strong) NSArray *objects;

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, assign, getter=isIncrementalSearchEnabled) BOOL incrementalSearchEnabled;

@end
