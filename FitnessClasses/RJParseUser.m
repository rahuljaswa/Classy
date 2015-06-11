//
//  RJParseUser.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseUser.h"


@implementation RJParseUser

@dynamic classesInstructed;
@dynamic instructor;
@dynamic name;
@dynamic profilePicture;
@dynamic twitterDigitsUserID;

+ (void)load {
    [self registerSubclass];
}

@end
