//
//  RJParseUser.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseUser.h"


@implementation RJParseUser

@dynamic admin;
@dynamic appStoreCreditEarnDates;
@dynamic email;
@dynamic facebookCreditEarnDates;
@dynamic instructor;
@dynamic name;
@dynamic profilePicture;
@dynamic showAllEarnCreditsOptions;
@dynamic subscriptionExpirationDate;
@dynamic tips;
@dynamic twitterCreditEarnDates;
@dynamic twitterDigitsUserID;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

#pragma mark - Public Instance Methods

- (BOOL)hasCurrentSubscription {
    return (self.subscriptionExpirationDate && (self.subscriptionExpirationDate == [self.subscriptionExpirationDate laterDate:[NSDate date]]));
}

- (NSUInteger)hash {
    return [self.objectId hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) { return YES; }
    if ([object class] != [self class]) { return NO; }
    PFObject *otherPFObject = (PFObject *)object;
    return [self.objectId isEqualToString:otherPFObject.objectId];
}

@end
