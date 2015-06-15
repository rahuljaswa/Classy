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
@dynamic comments;
@dynamic creditsCost;
@dynamic creditsSaleCost;
@dynamic coverArtURL;
@dynamic instructionQueue;
@dynamic instructor;
@dynamic length;
@dynamic likes;
@dynamic name;
@dynamic plays;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Class";
}

@end
