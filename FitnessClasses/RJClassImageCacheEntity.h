//
//  RJClassImageCacheEntity.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <FastImageCache/FICEntity.h>
@import CoreGraphics;
@import Foundation;

FOUNDATION_EXPORT NSString *const kRJImageFormatFamilyClass;
FOUNDATION_EXPORT NSString *const kRJClassImageFormatCardSquare16BitBGR;
FOUNDATION_EXPORT NSString *const kRJClassImageFormatCard16BitBGR;
FOUNDATION_EXPORT CGSize const kRJClassImageSizeCard;


@interface RJClassImageCacheEntity : NSObject <FICEntity>

- (instancetype)initWithClassImageURL:(NSURL *)imageURL objectID:(NSString *)objectID;

@end
