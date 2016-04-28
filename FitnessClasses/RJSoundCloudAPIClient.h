//
//  RJSoundCloudAPIClient.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/5/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>


@class AVPlayer;
@class RJSoundCloudTrack;

@interface RJSoundCloudAPIClient : AFHTTPSessionManager

+ (instancetype)sharedAPIClient;

- (NSURL *)authenticatingStreamURLWithTrackID:(NSString *)trackID;
- (NSURL *)authenticatingStreamURLWithStreamURL:(NSString *)streamURL;
- (void)getTrackWithTrackID:(NSString *)trackID completion:(void (^)(RJSoundCloudTrack *track))completion;
- (void)getTracksMatchingKeyword:(NSString *)keyword completion:(void (^)(NSArray *tracks))completion;

@end
