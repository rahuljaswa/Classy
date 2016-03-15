//
//  RJGalleryCell_FastImageCache.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryCell.h"
#import <FastImageCache/FICEntity.h>


@interface RJGalleryCell ()

@property (nonatomic, strong) id<FICEntity> entity;
@property (nonatomic, strong) NSString *formatName;

@end
