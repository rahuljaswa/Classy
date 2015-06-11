//
//  UIImageView+FastImageCache.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <FastImageCache/FICEntity.h>
#import <UIKit/UIKit.h>


@interface UIImageView (FastImageCache)

- (void)setImageEntity:(NSObject<FICEntity> *)entity formatName:(NSString *)formatName placeholder:(UIImage *)placeholder;

@end
