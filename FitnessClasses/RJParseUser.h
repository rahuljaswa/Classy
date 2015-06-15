//
//  RJParseUser.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@interface RJParseUser : PFUser

@property (nonatomic, strong) NSArray *appStoreCreditEarnDates;
@property (nonatomic, strong) PFRelation *classesInstructed;
@property (nonatomic, strong) NSArray *classesPurchased;
@property (nonatomic, strong) NSNumber *creditPurchases;
@property (nonatomic, strong) NSNumber *creditsAvailable;
@property (nonatomic, strong) NSArray *facebookCreditEarnDates;
@property (nonatomic, assign) BOOL instructor;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *tips;
@property (nonatomic, strong) NSArray *twitterCreditEarnDates;
@property (nonatomic, strong) NSString *twitterDigitsUserID;
@property (nonatomic, strong) PFFile *profilePicture;

@end
