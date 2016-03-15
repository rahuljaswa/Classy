//
//  RJSoundCloudTrack.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/7/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>


@interface RJSoundCloudTrack : NSObject

@property (nonatomic, strong, readonly) NSString *artist;
@property (nonatomic, strong, readonly) NSString *artworkURL;
@property (nonatomic, assign, readonly) CGFloat length;
@property (nonatomic, strong, readonly) NSString *permalinkURL;
@property (nonatomic, assign, readonly) BOOL streamable;
@property (nonatomic, strong, readonly) NSString *streamURL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *trackID;

+ (instancetype)trackWithJSONData:(NSDictionary *)data;

@end
