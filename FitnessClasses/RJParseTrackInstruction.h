//
//  RJParseTrackInstruction.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@class RJParseTrack;

@interface RJParseTrackInstruction : PFObject <PFSubclassing>

@property (nonatomic, strong) NSNumber *startPoint;
@property (nonatomic, strong) RJParseTrack *track;

@end
