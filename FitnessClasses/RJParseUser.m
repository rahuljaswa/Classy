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
@dynamic classesPurchased;
@dynamic creditPurchases;
@dynamic creditsAvailable;
@dynamic email;
@dynamic facebookCreditEarnDates;
@dynamic instructor;
@dynamic name;
@dynamic profilePicture;
@dynamic showAllEarnCreditsOptions;
@dynamic tips;
@dynamic twitterCreditEarnDates;
@dynamic twitterDigitsUserID;

+ (void)load {
    [self registerSubclass];
}

@end
