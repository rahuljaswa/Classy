//
//  RJParseUser.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@interface RJParseUser : PFUser

@property (nonatomic, strong) PFRelation *classesInstructed;
@property (nonatomic, assign) BOOL instructor;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *twitterDigitsUserID;
@property (nonatomic, strong) PFFile *profilePicture;

@end
