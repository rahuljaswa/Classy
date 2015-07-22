//
//  RJParseClass.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseClass.h"
#import "RJParseTrack.h"


@implementation RJParseClass

@dynamic category;
@dynamic classType;
@dynamic comments;
@dynamic creditsCost;
@dynamic creditsSaleCost;
@dynamic coverArtURL;
@dynamic exerciseInstructions;
@dynamic instructor;
@dynamic length;
@dynamic likes;
@dynamic name;
@dynamic plays;
@dynamic tracks;

@synthesize formattedClassType;

#pragma mark - Public Getters

- (RJParseClassType)formattedClassType {
    return (RJParseClassType)[self.classType integerValue];
}

#pragma mark - Public Instance Methods

- (NSInteger)length {
    NSInteger length = 0;
    for (RJParseTrack *track in self.tracks) {
        length += [track.length integerValue];
    }
    return length;
}

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Class";
}

@end
