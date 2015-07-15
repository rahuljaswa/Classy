//
//  RJParseClass.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>

typedef NS_ENUM(NSInteger, RJParseClassType) {
    kRJParseClassTypeNone = -1,
    kRJParseClassTypeChoreographed,
    kRJParseClassTypeSelfPaced
};


@class RJParseCategory;
@class RJParseUser;

@interface RJParseClass : PFObject <PFSubclassing>

@property (nonatomic, strong) NSArray *audioQueue;
@property (nonatomic, strong) RJParseCategory *category;
@property (nonatomic, strong) NSNumber *classType;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSString *coverArtURL;
@property (nonatomic, strong) NSNumber *creditsCost;
@property (nonatomic, strong) NSNumber *creditsSaleCost;
@property (nonatomic, strong) NSArray *instructionQueue;
@property (nonatomic, strong) NSArray *instructions;
@property (nonatomic, strong) RJParseUser *instructor;
@property (nonatomic, strong) NSNumber *length;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *plays;

@property (nonatomic, assign) RJParseClassType formattedClassType;

@end
