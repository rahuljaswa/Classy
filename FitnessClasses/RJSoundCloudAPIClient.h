//
//  RJSoundCloudAPIClient.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/5/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"


@class AVPlayer;
@class RJSoundCloudTrack;

@interface RJSoundCloudAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedAPIClient;

- (NSURL *)authenticatingStreamURLWithTrackID:(NSString *)trackID;
- (NSURL *)authenticatingStreamURLWithStreamURL:(NSString *)streamURL;
- (void)getTrackWithTrackID:(NSString *)trackID success:(void (^)(RJSoundCloudTrack *track))success failure:(void (^)(NSError *error))failure;

@end
