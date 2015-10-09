//
//  RJInAppPurchaseHelper.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJInAppPurchaseHelper.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJUserDefaults.h"
#import <SVProgressHUD/SVProgressHUD.h>
@import Social;
@import StoreKit;

NSString *const kInstructorTipProductIdentifier = @"com.rahuljaswa.Classy.instructorTip";
NSString *const kTierOneMonthlySubscriptionProductIdentifier = @"com.rahuljaswa.Classy.tierOneMonthlySubscription";
NSString *const kTierOneYearlySubscriptionProductIdentifier = @"com.rahuljaswa.Classy.tierOneYearlySubscription";


@interface RJInAppPurchaseHelper () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, copy) void (^completion) (BOOL);
@property (nonatomic, copy) void (^priceLookupCompletion) (double, NSString *, double, NSString *);
@property (nonatomic, assign, getter=isTransactionInProgress) BOOL transactionInProgress;

@end


@implementation RJInAppPurchaseHelper

#pragma mark - Private Protocols - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    if (self.priceLookupCompletion) {
        NSDecimalNumber *monthlySubscriptionPrice = nil;
        NSString *formattedMonthlyPrice = nil;
        NSDecimalNumber *yearlySubscriptionPrice = nil;
        NSString *formattedYearlyPrice = nil;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        for (SKProduct *product in products) {
            if ([product.productIdentifier isEqualToString:kTierOneMonthlySubscriptionProductIdentifier]) {
                monthlySubscriptionPrice = product.price;
                [numberFormatter setLocale:product.priceLocale];
                formattedMonthlyPrice = [numberFormatter stringFromNumber:product.price];
            } else if ([product.productIdentifier isEqualToString:kTierOneYearlySubscriptionProductIdentifier]) {
                yearlySubscriptionPrice = product.price;
                [numberFormatter setLocale:product.priceLocale];
                formattedYearlyPrice = [numberFormatter stringFromNumber:product.price];
            }
        }
        
        self.priceLookupCompletion([monthlySubscriptionPrice doubleValue], formattedMonthlyPrice, [yearlySubscriptionPrice doubleValue], formattedYearlyPrice);
        self.priceLookupCompletion = nil;
    } else {
        SKProduct *product = [products firstObject];
        if (product) {
            SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
            [paymentQueue addTransactionObserver:self];
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [paymentQueue addPayment:payment];
        } else {
            [self callCompletionWithSuccess:NO];
        }
    }
}

#pragma mark - Private Protocols - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self saveSubscriptionReceiptForTransaction:transaction];
                [self completeTransaction:transaction WithSuccess:YES];
                break;
            case SKPaymentTransactionStateFailed:
                [self completeTransaction:transaction WithSuccess:NO];
                break;
            case SKPaymentTransactionStateRestored:
                [self saveSubscriptionReceiptForTransaction:transaction];
                [self completeTransaction:transaction WithSuccess:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Private Instance Methods

- (void)saveSubscriptionReceiptForTransaction:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:kTierOneMonthlySubscriptionProductIdentifier] ||
        [transaction.payment.productIdentifier isEqualToString:kTierOneYearlySubscriptionProductIdentifier])
    {
        NSURL *appStoreReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        if (appStoreReceiptURL) {
            NSError *error = nil;
            NSData *appStoreReceipt = [NSData dataWithContentsOfURL:appStoreReceiptURL
                                                            options:NSDataReadingMappedIfSafe
                                                              error:&error];
            if (error) {
                NSLog(@"Error downloaded iTunes receipt:\n\n%@", [error localizedDescription]);
            }
            if (appStoreReceipt) {
                [RJUserDefaults saveSubscriptionReceipt:appStoreReceipt];
            }
        }
    }
}

- (void)callCompletionWithSuccess:(BOOL)success {
    if (success) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success. Thanks!", nil) maskType:SVProgressHUDMaskTypeClear];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error. Try again!", nil) maskType:SVProgressHUDMaskTypeClear];
    }
    
    if (self.completion) {
        self.completion(success);
    }
    
    self.completion = nil;
    self.transactionInProgress = NO;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction WithSuccess:(BOOL)success {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self callCompletionWithSuccess:success];
}

- (BOOL)shouldAllowEarnBonusOptionWithPreviousEarnDates:(NSArray *)dates minDaysBetweenEarns:(NSUInteger)days {
    NSTimeInterval secondsInThirtyDays = 60*60*24*days;
    NSDate *currentDate = [NSDate date];
    for (NSDate *date in dates) {
        if ([currentDate timeIntervalSinceDate:date] < secondsInThirtyDays) {
            return NO;
        }
    }
    return YES;
}

- (void)startRequestWithProductIDS:(NSSet *)productIDS hud:(BOOL)hud {
    if (hud) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Contacting App Store..", nil) maskType:SVProgressHUDMaskTypeClear];
    }
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDS];
    request.delegate = self;
    [request start];
}

- (void)startRequestWithProductID:(NSString *)productID hud:(BOOL)hud {
    [self startRequestWithProductIDS:[NSSet setWithObject:productID] hud:hud];
}

#pragma mark - Public Instance Methods

- (void)earnBonusOption:(RJInAppPurchaseHelperBonusOption)option presentingViewController:(UIViewController *)presentingViewController completion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        NSString *textForShares = NSLocalizedString(@"I love working out with Classy! http://ios.getclassy.co", nil);
        
        RJParseUser *user = [RJParseUser currentUser];
        
        BOOL allowed;
        NSUInteger numberOfDays;
        
        switch (option) {
            case kRJInAppPurchaseHelperBonusOptionTwitterShare: {
                numberOfDays = 5;
                allowed = [self shouldAllowEarnBonusOptionWithPreviousEarnDates:user.twitterCreditEarnDates minDaysBetweenEarns:numberOfDays];
                if (allowed) {
                    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                        [composeViewController setInitialText:textForShares];
                        
                        __weak SLComposeViewController *weakComposeViewController = composeViewController;
                        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
                            [[weakComposeViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                            switch (result) {
                                case SLComposeViewControllerResultCancelled:
                                    if (completion) {
                                        completion(NO);
                                    }
                                    break;
                                case SLComposeViewControllerResultDone:
                                    [RJParseUtils completeEarnBonusOption:kRJInAppPurchaseHelperBonusOptionTwitterShare completion:completion];
                                    break;
                            }
                        }];
                        
                        [presentingViewController presentViewController:composeViewController animated:YES completion:nil];
                    } else if (completion) {
                        completion(NO);
                    }
                }
                break;
            }
            case kRJInAppPurchaseHelperBonusOptionAppStoreReview: {
                numberOfDays = 30;
                allowed = [self shouldAllowEarnBonusOptionWithPreviousEarnDates:user.appStoreCreditEarnDates minDaysBetweenEarns:numberOfDays];
                if (allowed) {
                    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=993370598&pageNumber=0&mt=8"];
                    UIApplication *application = [UIApplication sharedApplication];
                    if ([application canOpenURL:url]) {
                        [application openURL:url];
                        [RJParseUtils completeEarnBonusOption:kRJInAppPurchaseHelperBonusOptionAppStoreReview completion:completion];
                    } else if (completion) {
                        completion(NO);
                    }
                }
                break;
            }
        }
        
        if (!allowed) {
            NSString *status = [NSString stringWithFormat:NSLocalizedString(@"You can only do this once every %lu days!", nil), (unsigned long)numberOfDays];
            [SVProgressHUD showErrorWithStatus:status];
            if (completion) {
                completion(NO);
            }
        }
    }
}

- (void)purchaseMonthlySubscriptionWithCompletion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        self.transactionInProgress = YES;
        
        self.completion = ^(BOOL success) {
            if (success) {
                [RJParseUtils updateSubscriptionWithCompletion:completion];
            } else if (completion) {
                completion(NO);
            }
        };
        
        [self startRequestWithProductID:kTierOneMonthlySubscriptionProductIdentifier hud:YES];
    }
}

- (void)purchaseYearlySubscriptionWithCompletion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        self.transactionInProgress = YES;
        
        self.completion = ^(BOOL success) {
            if (success) {
                [RJParseUtils updateSubscriptionWithCompletion:completion];
            } else if (completion) {
                completion(NO);
            }
        };
        
        [self startRequestWithProductID:kTierOneYearlySubscriptionProductIdentifier hud:YES];
    }
}

- (void)tipInstructorForClass:(RJParseClass *)klass completion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        self.transactionInProgress = YES;
        self.completion = ^(BOOL success) {
            if (success) {
                [RJParseUtils incrementTipsForClass:klass completion:nil];
                [RJParseUtils incrementTipsForUser:[RJParseUser currentUser] completion:nil];
            }
            if (completion) {
                completion(success);
            }
        };
        
        [self startRequestWithProductID:kInstructorTipProductIdentifier hud:YES];
    }
}

- (void)getSubscriptionPricesWithCompletion:(void (^)(double, NSString *, double, NSString *))completion {
    if (!self.isTransactionInProgress) {
        [self startRequestWithProductIDS:[NSSet setWithObjects:kTierOneMonthlySubscriptionProductIdentifier, kTierOneYearlySubscriptionProductIdentifier, nil] hud:NO];
        self.priceLookupCompletion = completion;
    }
}

- (void)updateCurrentUserSubscriptionStatusWithReceiptData:(NSData *)receiptData completion:(void (^)(BOOL))completion {
#ifdef DEBUG
    BOOL debugMode = YES;
#else
    BOOL debugMode = NO;
#endif
    
    NSDictionary *productInfo = @{
                                  @"debugMode" : @(debugMode),
                                  @"receiptData" : receiptData,
                                  @"userObjectId" : [RJParseUser currentUser].objectId
                                  };
    [PFCloud callFunctionInBackground:@"validateReceipt"
                       withParameters:productInfo
                                block:^(id object, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error validating subscription receipt:\n\n%@", [error localizedDescription]);
                                    }
                                    if (completion) {
                                        completion(YES);
                                    }
                                }];
}

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static RJInAppPurchaseHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RJInAppPurchaseHelper alloc] init];
    });
    return sharedInstance;
}

@end
