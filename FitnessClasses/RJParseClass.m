//
//  RJParseClass.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseClass.h"


@implementation RJParseClass

@dynamic audioQueue;
@dynamic category;
@dynamic classType;
@dynamic comments;
@dynamic creditsCost;
@dynamic creditsSaleCost;
@dynamic coverArtURL;
@dynamic instructionQueue;
@dynamic instructions;
@dynamic instructor;
@dynamic length;
@dynamic likes;
@dynamic name;
@dynamic plays;

@synthesize formattedClassType;

#pragma mark - Public Getters

- (RJParseClassType)formattedClassType {
    return (RJParseClassType)[self.classType integerValue];
}

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Class";
}

@end
