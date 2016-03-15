//
//  RJInAppPurchaseHelper.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, RJInAppPurchaseHelperBonusOption) {
    kRJInAppPurchaseHelperBonusOptionTwitterShare,
    kRJInAppPurchaseHelperBonusOptionAppStoreReview
};


@class RJParseClass;
@class UIViewController;

@interface RJInAppPurchaseHelper : NSObject

+ (instancetype)sharedInstance;

- (void)earnBonusOption:(RJInAppPurchaseHelperBonusOption)option presentingViewController:(UIViewController *)presentingViewController completion:(void (^)(BOOL success))completion;

- (void)purchaseMonthlySubscriptionWithCompletion:(void (^)(BOOL success))completion;
- (void)purchaseYearlySubscriptionWithCompletion:(void (^)(BOOL success))completion;

- (void)tipInstructorForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;

- (void)getSubscriptionPricesWithCompletion:(void (^)(double monthlyPrice, NSString *formattedMonthlyPrice, double yearlyPrice, NSString *formattedYearlyPrice))completion;
- (void)updateCurrentUserSubscriptionStatusWithReceiptData:(NSData *)receiptData completion:(void (^)(BOOL success))completion;

- (void)restoreCompletedTransactionsWithCompletion:(void (^)(BOOL success))completion;

@end
