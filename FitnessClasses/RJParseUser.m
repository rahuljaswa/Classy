//
//  RJParseUser.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseSubscription.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"

static RJParseUser *_currentUser;


@implementation RJParseUser

@dynamic admin;
@dynamic appStoreCreditEarnDates;
@dynamic creditsAvailable;
@dynamic email;
@dynamic facebookCreditEarnDates;
@dynamic instructor;
@dynamic name;
@dynamic profilePicture;
@dynamic showAllEarnCreditsOptions;
@dynamic subscriptions;
@dynamic tips;
@dynamic twitterCreditEarnDates;
@dynamic twitterDigitsUserID;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (RJParseUser *)loadCurrentUserWithSubscriptionsWithCompletion:(void (^)(RJParseUser *))completion {
    if (_currentUser) {
        if (completion) {
            completion(_currentUser);
        }
        return _currentUser;
    } else {
        [RJParseUtils fetchCurrentUserWithCompletion:^(RJParseUser *user) {
            if (user) {
                [self setCurrentUserWithSubscriptionsSharedInstance:user];
            }
            if (completion) {
                completion(_currentUser);
            }
        }];
    }
    return nil;
}

+ (RJParseUser *)currentUserWithSubscriptions {
    return _currentUser;
}

+ (void)resetCurrentUser {
    _currentUser = nil;
}

+ (RJParseUser *)setCurrentUserWithSubscriptionsSharedInstance:(RJParseUser *)currentUserWithSubscriptions {
    if (currentUserWithSubscriptions) {
        _currentUser = currentUserWithSubscriptions;
        return _currentUser;
    } else {
        return nil;
    }
}

#pragma mark - Public Instance Methods

- (RJParseSubscription *)currentAppSubscription {
    RJParseSubscription *currentAppSubscription = nil;
    for (RJParseSubscription *subscription in self.subscriptions) {
        if ([subscription.bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            currentAppSubscription = subscription;
            break;
        }
    }
    return currentAppSubscription;
}

- (BOOL)hasCurrentSubscription {
    BOOL hasCurrentSubscription = NO;
    RJParseSubscription *subscription = [self currentAppSubscription];
    if (subscription && (subscription.expirationDate == [subscription.expirationDate laterDate:[NSDate date]])) {
        hasCurrentSubscription = YES;
    }
    return hasCurrentSubscription;
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
