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


@implementation RJUserDefaults

#pragma mark - Public Class Methods - Save

+ (void)saveDidShowTutorial {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kRJUserDefaultsHasShownTutorialKey];
}

+ (void)saveSubscriptionReceipt:(NSData *)receiptData {
    [[NSUserDefaults standardUserDefaults] setObject:receiptData forKey:kRJUserDefaultsSubscriptionReceiptDataKey];
}

#pragma mark - Public Class Methods - Retrieve

+ (NSData *)subscriptionReceipt {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRJUserDefaultsSubscriptionReceiptDataKey];
}

+ (BOOL)shouldShowTutorialOnLaunch {
    NSNumber *hasShownTutorial = [[NSUserDefaults standardUserDefaults] objectForKey:kRJUserDefaultsHasShownTutorialKey];
    return (!hasShownTutorial || ![hasShownTutorial boolValue]);
}

@end
