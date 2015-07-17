//
//  RJEquipmentViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJSingleSelectionViewController;

@protocol RJSingleSelectionViewControllerDelegate <NSObject>

- (void)singleSelectionViewController:(RJSingleSelectionViewController *)viewController didSelectObject:(NSObject *)object;

@end


@class RJSingleSelectionViewController;

@protocol RJSingleSelectionViewControllerDataSource <NSObject>

- (NSString *)singleSelectionViewController:(RJSingleSelectionViewController *)viewController titleForObject:(NSObject *)object;

@end


@interface RJSingleSelectionViewController : UITableViewController

@property (nonatomic, weak) id<RJSingleSelectionViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<RJSingleSelectionViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) NSObject *selectedObject;
@property (nonatomic, strong) NSArray *objects;

@end
