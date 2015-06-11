//
//  RJParseClass.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>

@class RJParseCategory;
@class RJParseUser;

@interface RJParseClass : PFObject <PFSubclassing>

@property (nonatomic, strong) NSArray *audioQueue;
@property (nonatomic, strong) RJParseCategory *category;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSString *coverArtURL;
@property (nonatomic, strong) NSArray *instructionQueue;
@property (nonatomic, strong) RJParseUser *instructor;
@property (nonatomic, strong) NSNumber *length;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *plays;

@end
