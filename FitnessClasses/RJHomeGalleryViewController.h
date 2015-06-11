//
//  RJHomeGalleryViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryViewController.h"


@class RJHomeGalleryViewController;
@class RJParseClass;

@protocol RJHomeGalleryViewControllerDelegate <NSObject>

- (void)homeGalleryViewController:(RJHomeGalleryViewController *)homeGalleryViewController wantsPlayForClass:(RJParseClass *)klass autoPlay:(BOOL)autoPlay;

@end


@class RJParseCategory;
@class RJParseClass;

@interface RJHomeGalleryViewController : RJGalleryViewController

@property (nonatomic, strong, readonly) NSArray *classes;
@property (nonatomic, weak) id<RJHomeGalleryViewControllerDelegate> homeGalleryDelegate;

- (void)reloadWithCompletion:(void (^)(BOOL success))completion;

- (void)switchToClassesForCategory:(RJParseCategory *)category completion:(void (^)(void))completion;
- (void)switchToPopularClassesWithCompletion:(void (^)(void))completion;
- (void)switchToNewClassesWithCompletion:(void (^)(void))completion;

@end
