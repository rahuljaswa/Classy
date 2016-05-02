//
//  RJInAppPurchaseHelper.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJInAppPurchaseHelper.h"
#import "RJParseKey.h"
#import "RJParseSubscription.h"
#import "RJParseTemplate.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJUserDefaults.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Social/Social.h>
#import <StoreKit/StoreKit.h>

NSString *const kInstructorTipProductIdentifier = @"instructorTip";
NSString *const kTierOneSubscriptionMonthlyProductIdentifier = @"tierOneSubscriptionMonthly";
NSString *const kTierOneSubscriptionYearlyProductIdentifier = @"tierOneSubscriptionYearly";


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
            if ([product.productIdentifier isEqualToString:[[self class] tierOneSubscriptionMonthlyProductIdentifier]]) {
                monthlySubscriptionPrice = product.price;
                [numberFormatter setLocale:product.priceLocale];
                formattedMonthlyPrice = [numberFormatter stringFromNumber:product.price];
            } else if ([product.productIdentifier isEqualToString:[[self class] tierOneSubscriptionYearlyProductIdentifier]]) {
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
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateDeferred:
                [self completeTransaction:transaction WithSuccess:NO];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Private Instance Methods

- (void)saveSubscriptionReceiptForTransaction:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:[[self class] tierOneSubscriptionMonthlyProductIdentifier]] ||
        [transaction.payment.productIdentifier isEqualToString:[[self class] tierOneSubscriptionYearlyProductIdentifier]])
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
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    if (success) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success. Thanks!", nil)];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error. Try again!", nil)];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    
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
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Contacting App Store..", nil)];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
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
        RJParseTemplate *template = [RJParseTemplate currentTemplate];
        NSString *textForShares = [NSString stringWithFormat:NSLocalizedString(@"I love working out with %@!\n%@", nil), template.name, template.downloadURL];
        
        RJParseUser *currentUser = [RJParseUser currentUserWithSubscriptions];
        
        BOOL allowed;
        NSUInteger numberOfDays;
        
        switch (option) {
            case kRJInAppPurchaseHelperBonusOptionTwitterShare: {
                numberOfDays = 5;
                allowed = [self shouldAllowEarnBonusOptionWithPreviousEarnDates:currentUser.twitterCreditEarnDates minDaysBetweenEarns:numberOfDays];
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
                allowed = [self shouldAllowEarnBonusOptionWithPreviousEarnDates:currentUser.appStoreCreditEarnDates minDaysBetweenEarns:numberOfDays];
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
        self.completion = completion;
        
        [self startRequestWithProductID:[[self class] tierOneSubscriptionMonthlyProductIdentifier] hud:YES];
    }
}

- (void)purchaseYearlySubscriptionWithCompletion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        self.transactionInProgress = YES;
        
        self.completion = completion;
        
        [self startRequestWithProductID:[[self class] tierOneSubscriptionYearlyProductIdentifier] hud:YES];
    }
}

- (void)tipInstructorForClass:(RJParseClass *)klass completion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        self.transactionInProgress = YES;
        self.completion = ^(BOOL success) {
            if (success) {
                [RJParseUtils incrementTipsForClass:klass completion:nil];
                RJParseUser *currentUser = [RJParseUser currentUserWithSubscriptions];
                if (currentUser) {
                    [RJParseUtils incrementTipsForUser:currentUser completion:nil];
                }
            }
            if (completion) {
                completion(success);
            }
        };
        
        [self startRequestWithProductID:[[self class] instructorTipProductIdentifier] hud:YES];
    }
}

- (void)getSubscriptionPricesWithCompletion:(void (^)(double, NSString *, double, NSString *))completion {
    if (!self.isTransactionInProgress) {
        [self startRequestWithProductIDS:[NSSet setWithObjects:[[self class] tierOneSubscriptionMonthlyProductIdentifier], [[self class] tierOneSubscriptionYearlyProductIdentifier], nil] hud:NO];
        self.priceLookupCompletion = completion;
    }
}

- (void)updateCurrentUserSubscriptionStatusWithReceiptData:(NSData *)receiptData completion:(void (^)(BOOL))completion {
    [RJParseUtils fetchKeyForIdentifier:kRJParseKeyAppleInAppPurchaseKey completion:^(RJParseKey *key) {
        if (key) {
            NSError *error;
            NSDictionary *requestContents = @{
                                              @"receipt-data": [receiptData base64EncodedStringWithOptions:0],
                                              @"password": key.secret
                                              };
            NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                                  options:0
                                                                    error:&error];
            
            if (requestData) {
#ifdef DEBUG
                NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
#else
                NSURL *storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
#endif
                
                NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
                [storeRequest setHTTPMethod:@"POST"];
                [storeRequest setHTTPBody:requestData];
                
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           if (connectionError) {
                                               NSLog(@"Error connecting to Apple Receipt Validation Server\n\n%@", [error localizedDescription]);
                                           } else {
                                               NSError *error;
                                               NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                               if (jsonResponse) {
                                                   RJParseUser *currentUser = [RJParseUser currentUserWithSubscriptions];
                                                   NSString *jsonSubscriptionExpirationDate = [jsonResponse[@"latest_receipt_info"] lastObject][@"expires_date"];
                                                   
                                                   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                   formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss VV";
                                                   NSDate *expirationDate = [formatter dateFromString:jsonSubscriptionExpirationDate];
                                                   
                                                   if ([expirationDate laterDate:[NSDate date]] == expirationDate) {
                                                       RJParseSubscription *subscription = [currentUser currentAppSubscription];
                                                       if (!subscription) {
                                                           subscription = [RJParseSubscription object];
                                                           subscription.bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                                                           [currentUser addUniqueObject:subscription forKey:NSStringFromSelector(@selector(subscriptions))];
                                                       }
                                                       subscription.expirationDate = expirationDate;
                                                   } else {
                                                       [RJUserDefaults clearSubscriptionReceipt];
                                                   }
                                                   
                                                   [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                       if (completion) {
                                                           completion(succeeded);
                                                       }
                                                   }];
                                               } else {
                                                   NSLog(@"Error creating JSON object with response data\n\n%@", [error localizedDescription]);
                                                   if (completion) {
                                                       completion(NO);
                                                   }
                                               }
                                           }
                                       }];
            } else {
                NSLog(@"Error retrieving data from JSON Object\n\n%@", [error localizedDescription]);
                if (completion) {
                    completion(NO);
                }
            }
        } else if (completion) {
            completion(NO);
        }
    }];
}

- (void)restoreCompletedTransactionsWithCompletion:(void (^)(BOOL))completion {
    self.completion = completion;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Restoring purchases...", nil)];
    
    SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
    [paymentQueue addTransactionObserver:self];
    [paymentQueue restoreCompletedTransactions];
}

#pragma mark - Private Class Methods

+ (NSString *)instructorTipProductIdentifier {
    return [NSString stringWithFormat:@"%@.%@", [[NSBundle mainBundle] bundleIdentifier], kInstructorTipProductIdentifier];
}

+ (NSString *)tierOneSubscriptionMonthlyProductIdentifier {
    return [NSString stringWithFormat:@"%@.%@", [[NSBundle mainBundle] bundleIdentifier], kTierOneSubscriptionMonthlyProductIdentifier];
}

+ (NSString *)tierOneSubscriptionYearlyProductIdentifier {
    return [NSString stringWithFormat:@"%@.%@", [[NSBundle mainBundle] bundleIdentifier], kTierOneSubscriptionYearlyProductIdentifier];
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
