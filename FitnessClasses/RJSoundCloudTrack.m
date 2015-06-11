//
//  RJSoundCloudTrack.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/7/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJSoundCloudTrack.h"


@interface RJSoundCloudTrack ()

@property (nonatomic, strong, readwrite) NSString *artist;
@property (nonatomic, strong, readwrite) NSString *artworkURL;
@property (nonatomic, assign, readwrite) CGFloat length;
@property (nonatomic, strong, readwrite) NSString *permalinkURL;
@property (nonatomic, strong, readwrite) NSString *streamURL;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *trackID;

@end


@implementation RJSoundCloudTrack

#pragma mark - Public Class Methods

+ (instancetype)trackWithJSONData:(NSDictionary *)data {
    RJSoundCloudTrack *track = [[self alloc] init];
    track.artist = data[@"user"][@"username"];
    track.length = [data[@"duration"] floatValue];
    track.permalinkURL = data[@"permalink_url"];
    track.title = data[@"title"];
    track.trackID = [data[@"id"] stringValue];
    
    NSString *artworkURL = data[@"artwork_url"];
    if ([artworkURL isKindOfClass:[NSNull class]]) {
        artworkURL = data[@"user"][@"avatar_url"];
        if ([artworkURL isKindOfClass:[NSNull class]]) {
            artworkURL = nil;
        }
    }
    track.artworkURL = [artworkURL stringByReplacingOccurrencesOfString:@"-large." withString:@"-t500x500."];
    
    NSString *streamURL = data[@"stream_url"];
    if (![streamURL isKindOfClass:[NSNull class]]) {
        track.streamURL = streamURL;
    }
    
    return track;
}

@end
