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

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController subtitleForObject:(NSObject *)object;

@end


@class PFObject;

@interface RJSinglePFObjectSelectionViewController : UITableViewController

@property (nonatomic, weak) id<RJSingleSelectionViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<RJSingleSelectionViewControllerDelegate> delegate;

@property (nonatomic, strong) PFObject *selectedObject;
@property (nonatomic, strong) NSArray *objects;

@end
