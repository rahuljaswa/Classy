//
//  RJParseKey.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 10/15/15.
//  Copyright © 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseKey.h"

NSString *kRJParseKeyAppleInAppPurchaseKey = @"RJParseKeyAppleInAppPurchaseKey";


@implementation RJParseKey

@dynamic identifier;
@dynamic secret;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Key";
}

@end
