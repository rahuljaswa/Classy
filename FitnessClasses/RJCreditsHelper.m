//
//  RJCreditsHelper.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreditsHelper.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import <SVProgressHUD/SVProgressHUD.h>
@import Social;
@import StoreKit;


@interface RJCreditsHelper () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, copy) void (^completion) (BOOL);
@property (nonatomic, assign, getter=isTransactionInProgress) BOOL transactionInProgress;

@end


@implementation RJCreditsHelper


#pragma mark - Private Protocols - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *product = [response.products firstObject];
    if (product) {
        SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
        [paymentQueue addTransactionObserver:self];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [paymentQueue addPayment:payment];
    } else {
        [self callCompletionWithSuccess:NO];
    }
}

#pragma mark - Private Protocols - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction WithSuccess:YES];
                break;
            case SKPaymentTransactionStateFailed:
                [self completeTransaction:transaction WithSuccess:NO];
                break;
            case SKPaymentTransactionStateRestored:
                [self completeTransaction:transaction WithSuccess:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Private Instance Methods

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

- (BOOL)shouldAllowEarnCreditsOptionWithPreviousEarnDates:(NSArray *)dates minDaysBetweenEarns:(NSUInteger)days {
    NSTimeInterval secondsInThirtyDays = 60*60*24*days;
    NSDate *currentDate = [NSDate date];
    for (NSDate *date in dates) {
        if ([currentDate timeIntervalSinceDate:date] < secondsInThirtyDays) {
            return NO;
        }
    }
    return YES;
}

- (void)startRequestWithProductID:(NSString *)productID {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Contacting App Store..", nil) maskType:SVProgressHUDMaskTypeClear];
    NSSet *products = [NSSet setWithObjects:productID, nil];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
    request.delegate = self;
    [request start];
}

#pragma mark - Public Instance Methods

- (void)earnCreditsOption:(RJCreditsHelperEarnCreditsOption)option presentingViewController:(UIViewController *)presentingViewController completion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        NSString *textForShares = NSLocalizedString(@"I love working out with Classy! http://ios.getclassy.co", nil);
        
        RJParseUser *user = [RJParseUser currentUser];
        
        BOOL allowed;
        NSUInteger numberOfDays;
        
        switch (option) {
            case kRJCreditsHelperEarnCreditsOptionTwitterShare: {
                numberOfDays = 5;
                allowed = [self shouldAllowEarnCreditsOptionWithPreviousEarnDates:user.twitterCreditEarnDates minDaysBetweenEarns:numberOfDays];
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
                                    [RJParseUtils completeEarnCreditsOption:kRJCreditsHelperEarnCreditsOptionTwitterShare completion:completion];
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
            case kRJCreditsHelperEarnCreditsOptionFacebookShare: {
                numberOfDays = 5;
                allowed = [self shouldAllowEarnCreditsOptionWithPreviousEarnDates:user.facebookCreditEarnDates minDaysBetweenEarns:numberOfDays];
                if (allowed) {
                    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
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
                                    [RJParseUtils completeEarnCreditsOption:kRJCreditsHelperEarnCreditsOptionFacebookShare completion:completion];
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
            case kRJCreditsHelperEarnCreditsOptionAppStoreReview: {
                numberOfDays = 30;
                allowed = [self shouldAllowEarnCreditsOptionWithPreviousEarnDates:user.appStoreCreditEarnDates minDaysBetweenEarns:numberOfDays];
                if (allowed) {
                    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=993370598&pageNumber=0&mt=8"];
                    UIApplication *application = [UIApplication sharedApplication];
                    if ([application canOpenURL:url]) {
                        [application openURL:url];
                        [RJParseUtils completeEarnCreditsOption:kRJCreditsHelperEarnCreditsOptionAppStoreReview completion:completion];
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

- (void)purchaseCreditsPackage:(RJCreditsHelperCreditPackage)package completion:(void (^)(BOOL))completion {
    if (!self.isTransactionInProgress) {
        self.transactionInProgress = YES;
        
        __block NSString *productID = nil;
        __block NSNumber *creditsPurchased = nil;
        switch (package) {
            case kRJCreditsHelperCreditPackageOne:
                productID = @"com.rahuljaswa.Classy.oneCredit";
                creditsPurchased = @1;
                break;
            case kRJCreditsHelperCreditPackageFive:
                productID = @"com.rahuljaswa.Classy.fiveCredits";
                creditsPurchased = @5;
                break;
            case kRJCreditsHelperCreditPackageTen:
                productID = @"com.rahuljaswa.Classy.tenCredits";
                creditsPurchased = @10;
                break;
            default:
                break;
        }
        
        self.completion = ^(BOOL success) {
            if (success) {
                [RJParseUtils incrementCreditPurchasesForUser:[RJParseUser currentUser] forCreditsPurchased:creditsPurchased completion:nil];
            }
            if (completion) {
                completion(success);
            }
        };
        
        [self startRequestWithProductID:productID];
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
        
        [self startRequestWithProductID:@"com.rahuljaswa.Classy.instructorTip"];
    }
}

#pragma mark - Public Class Methods

+ (instancetype)sharedInstance {
    static RJCreditsHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RJCreditsHelper alloc] init];
    });
    return sharedInstance;
}

@end
