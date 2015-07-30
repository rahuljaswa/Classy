//
//  RJCreateEditChoreographedClassCollectionViewLayout.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat kCreateEditChoreographedClassCollectionViewLayoutTickLength;


@interface RJCreateEditChoreographedClassCollectionViewLayout : UICollectionViewLayout

+ (NSInteger)durationForLength:(CGFloat)length;
+ (CGFloat)lengthForDuration:(NSInteger)duration;
+ (NSInteger)startPointForOriginY:(CGFloat)originY;

@end
