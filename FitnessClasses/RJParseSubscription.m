//
//  RJParseSubscription.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 10/18/15.
//  Copyright © 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseSubscription.h"


@implementation RJParseSubscription

@dynamic bundleIdentifier;
@dynamic expirationDate;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Subscription";
}

@end
