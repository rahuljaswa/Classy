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

- (void)getTracksMatchingKeyword:(NSString *)keyword completion:(void (^)(NSArray *))completion {
    NSString *path = [NSString stringWithFormat:@"/tracks?limit=20&q=%@", [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *params = @{ @"client_id" : kClientID };
    [self GET:path parameters:params progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          if (completion) {
              NSMutableArray *tracks = [[NSMutableArray alloc] init];
              for (id jsonObject in responseObject) {
                  RJSoundCloudTrack *track = [RJSoundCloudTrack trackWithJSONData:jsonObject];
                  [tracks addObject:track];
              }
              NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(streamable == %@) && (length <= 600)", @YES];
              completion([tracks filteredArrayUsingPredicate:predicate]);
          }
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"Error fetching tracks from SoundCloud matching keyword %@\n\n%@", keyword, [error localizedDescription]);
          if (completion) {
              completion(nil);
          }
      }];
}

- (void)getTracksWithTrackIDs:(NSString *)trackIDs completion:(void (^)(NSArray *))completion {
    NSString *path = [NSString stringWithFormat:@"/tracks?limit=200&ids=%@", trackIDs];
    NSDictionary *params = @{ @"client_id" : kClientID };
    [self GET:path parameters:params progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          if (completion) {
              NSMutableArray *tracks = [[NSMutableArray alloc] init];
              for (id jsonObject in responseObject) {
                  RJSoundCloudTrack *track = [RJSoundCloudTrack trackWithJSONData:jsonObject];
                  [tracks addObject:track];
              }
              completion(tracks);
          }
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"Error fetching tracks from SoundCloud with IDs %@\n\n%@", trackIDs, [error localizedDescription]);
          if (completion) {
              completion(nil);
          }
      }];
}

- (void)getTrackWithTrackID:(NSString *)trackID completion:(void (^)(RJSoundCloudTrack *))completion {
    NSString *path = [NSString stringWithFormat:@"/tracks/%@.json", trackID];
    NSDictionary *params = @{ @"client_id" : kClientID };
    [self GET:path parameters:params progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          if (completion) {
              RJSoundCloudTrack *track = [RJSoundCloudTrack trackWithJSONData:responseObject];
              completion(track);
          }
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"Error fetching track from SoundCloud with ID %@\n\n%@", trackID, [error localizedDescription]);
          if (completion) {
              completion(nil);
          }
      }];    
}

#pragma mark - Public Class Methods

+ (instancetype)sharedAPIClient {
    static RJSoundCloudAPIClient *_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"https://api.soundcloud.com"];
        _client = [[RJSoundCloudAPIClient alloc] initWithBaseURL:baseURL];
    });
    return _client;
}

@end
