//
//  RJSoundCloudAPIClient.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/5/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJSoundCloudAPIClient.h"
#import "RJSoundCloudTrack.h"

static NSString *const kClientID = @"872e4a8be87a50cbd405c46f23763960";


@implementation RJSoundCloudAPIClient

#pragma mark - Public Instance Methods

- (NSURL *)authenticatingStreamURLWithTrackID:(NSString *)trackID {
    NSString *path = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/stream?client_id=%@", trackID, kClientID];
    return [NSURL URLWithString:path];
}

- (NSURL *)authenticatingStreamURLWithStreamURL:(NSString *)streamURL {
    NSString *path = [NSString stringWithFormat:@"%@?client_id=%@", streamURL, kClientID];
    return [NSURL URLWithString:path];
}

- (void)getTrackWithTrackID:(NSString *)trackID success:(void (^)(RJSoundCloudTrack *))success failure:(void (^)(NSError *))failure {
    NSString *path = [NSString stringWithFormat:@"/tracks/%@.json", trackID];
    NSDictionary *params = @{ @"client_id" : kClientID };
    [self GET:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (success) {
              RJSoundCloudTrack *track = [RJSoundCloudTrack trackWithJSONData:responseObject];
              success(track);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

#pragma mark - Public Class Methods

+ (instancetype)sharedAPIClient {
    static RJSoundCloudAPIClient *_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://api.soundcloud.com"];
        _client = [[RJSoundCloudAPIClient alloc] initWithBaseURL:baseURL];
    });
    return _client;
}

@end
