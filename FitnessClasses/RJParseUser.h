//
//  RJParseUser.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@class RJParseSubscription;

@interface RJParseUser : PFUser

@property (nonatomic, assign) BOOL admin;
@property (nonatomic, strong) NSArray *appStoreCreditEarnDates;
@property (nonatomic, strong) NSNumber *creditsAvailable;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSArray *facebookCreditEarnDates;
@property (nonatomic, assign) BOOL instructor;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL showAllEarnCreditsOptions;
@property (nonatomic, strong) NSArray *subscriptions;
@property (nonatomic, strong) NSNumber *tips;
@property (nonatomic, strong) NSArray *twitterCreditEarnDates;
@property (nonatomic, strong) NSString *twitterDigitsUserID;
@property (nonatomic, strong) PFFile *profilePicture;

- (RJParseSubscription *)currentAppSubscription;
- (BOOL)hasCurrentSubscription;

+ (RJParseUser *)loadCurrentUserWithSubscriptionsWithCompletion:(void (^)(RJParseUser *currentUser))completion;
+ (void)resetCurrentUser;
+ (RJParseUser *)setCurrentUserWithSubscriptionsSharedInstance:(RJParseUser *)currentUserWithSubscriptions;

@end
