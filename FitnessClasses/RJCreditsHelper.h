//
//  RJCreditsHelper.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RJCreditsHelperCreditPackage) {
    kRJCreditsHelperCreditPackageOne,
    kRJCreditsHelperCreditPackageFive,
    kRJCreditsHelperCreditPackageTen
};

typedef NS_ENUM(NSUInteger, RJCreditsHelperEarnCreditsOption) {
    kRJCreditsHelperEarnCreditsOptionFacebookShare,
    kRJCreditsHelperEarnCreditsOptionTwitterShare,
    kRJCreditsHelperEarnCreditsOptionAppStoreReview
};


@class RJParseClass;
@class UIViewController;

@interface RJCreditsHelper : NSObject

+ (instancetype)sharedInstance;

- (void)earnCreditsOption:(RJCreditsHelperEarnCreditsOption)option presentingViewController:(UIViewController *)presentingViewController completion:(void (^)(BOOL success))completion;
- (void)purchaseCreditsPackage:(RJCreditsHelperCreditPackage)package completion:(void (^)(BOOL success))completion;
- (void)tipInstructorForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;

@end
