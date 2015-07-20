//
//  RJParseClass.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseClass.h"
#import "RJParseTrack.h"
#import "RJParseTrackInstruction.h"


@implementation RJParseClass

@dynamic trackInstructions;
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

@synthesize formattedClassType;

#pragma mark - Public Getters

- (RJParseClassType)formattedClassType {
    return (RJParseClassType)[self.classType integerValue];
}

#pragma mark - Public Instance Methods

- (NSInteger)length {
    NSInteger latestPointInDuration = 0;
    for (RJParseTrackInstruction *trackInstruction in self.trackInstructions) {
        NSInteger trackLatestPointInDuration = ([trackInstruction.startPoint integerValue] + [trackInstruction.track.length integerValue]);
        if (trackLatestPointInDuration > latestPointInDuration) {
            latestPointInDuration = trackLatestPointInDuration;
        }
    }
    return latestPointInDuration;
}

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Class";
}

@end
