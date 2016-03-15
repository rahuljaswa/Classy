//
//  RJParseTrack.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseTrack.h"


@implementation RJParseTrack

@dynamic artist;
@dynamic artworkURL;
@dynamic length;
@dynamic permalinkURL;
@dynamic soundCloudTrackID;
@dynamic streamURL;
@dynamic title;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Track";
}

@end
