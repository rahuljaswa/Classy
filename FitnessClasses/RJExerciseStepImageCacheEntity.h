//
//  RJExerciseStepImageCacheEntity.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <FastImageCache/FICEntity.h>
#import <CoreGraphics/CoreGraphics.h>

FOUNDATION_EXPORT NSString *const kRJImageFormatFamilyExerciseStep;
FOUNDATION_EXPORT NSString *const kRJExerciseStepImageFormatFullScreen16BitBGR;


@interface RJExerciseStepImageCacheEntity : NSObject <FICEntity>

- (instancetype)initWithImageURL:(NSURL *)imageURL objectID:(NSString *)objectID;

@end
