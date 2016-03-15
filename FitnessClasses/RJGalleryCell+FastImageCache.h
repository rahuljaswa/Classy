//
//  RJGalleryCell+FastImageCache.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryCell.h"
#import <FastImageCache/FICEntity.h>


@interface RJGalleryCell (FastImageCache)

- (void)updateWithImageEntity:(id<FICEntity>)entity formatName:(NSString *)formatName placeholder:(UIImage *)placeholder;

@end
