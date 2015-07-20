//
//  RJParseTrackInstruction.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseTrackInstruction.h"


@implementation RJParseTrackInstruction

@dynamic startPoint;
@dynamic track;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"TrackInstruction";
}

@end
