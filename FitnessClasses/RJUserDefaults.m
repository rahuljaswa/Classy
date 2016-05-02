//
//  RJUserDefaults.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/15/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJUserDefaults.h"

static NSString *const kRJUserDefaultsHasShownTutorialKey = @"RJUserDefaultsHasShownTutorialKey";
static NSString *const kRJUserDefaultsSubscriptionReceiptDataKey = @"RJUserDefaultsSubscriptionReceiptDataKey";
static NSString *const kRJUserDefaultsSubscriptionReceiptDataKeySandbox = @"RJUserDefaultsSubscriptionReceiptDataKeySandbox";


@implementation RJUserDefaults

#pragma mark - Public Class Methods - Save

+ (void)saveDidShowTutorial {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kRJUserDefaultsHasShownTutorialKey];
}

+ (void)saveSubscriptionReceipt:(NSData *)receiptData {
#ifdef DEBUG
    [[NSUserDefaults standardUserDefaults] setObject:receiptData forKey:kRJUserDefaultsSubscriptionReceiptDataKeySandbox];
#else
    [[NSUserDefaults standardUserDefaults] setObject:receiptData forKey:kRJUserDefaultsSubscriptionReceiptDataKey];
#endif
}

#pragma mark - Public Class Methods - Retrieve

+ (NSData *)subscriptionReceipt {
#ifdef DEBUG
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRJUserDefaultsSubscriptionReceiptDataKeySandbox];
#else
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRJUserDefaultsSubscriptionReceiptDataKey];
#endif
}

+ (BOOL)shouldShowTutorialOnLaunch {
    NSNumber *hasShownTutorial = [[NSUserDefaults standardUserDefaults] objectForKey:kRJUserDefaultsHasShownTutorialKey];
    return (!hasShownTutorial || ![hasShownTutorial boolValue]);
}

+ (void)clearSubscriptionReceipt {
#ifdef DEBUG
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRJUserDefaultsSubscriptionReceiptDataKeySandbox];
#else
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRJUserDefaultsSubscriptionReceiptDataKey];
#endif
}

@end
