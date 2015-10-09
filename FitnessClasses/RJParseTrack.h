//
//  RJParseTrack.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"


@interface RJParseTrack : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *artworkURL;
@property (nonatomic, strong) NSNumber *length;
@property (nonatomic, strong) NSString *permalinkURL;
@property (nonatomic, strong) NSString *soundCloudTrackID;
@property (nonatomic, strong) NSString *streamURL;
@property (nonatomic, strong) NSString *title;

@end
