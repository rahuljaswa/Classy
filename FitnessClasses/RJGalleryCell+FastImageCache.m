//
//  RJGalleryCell+FastImageCache.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryCell_FastImageCache.h"
#import "RJGalleryCell+FastImageCache.h"
#import "UIImageView+FastImageCache.h"
#import <FastImageCache/FICImageCache.h>


@implementation RJGalleryCell (FastImageCache)

- (void)dealloc {
    [[FICImageCache sharedImageCache] cancelImageRetrievalForEntity:self.entity withFormatName:self.formatName];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[FICImageCache sharedImageCache] cancelImageRetrievalForEntity:self.entity withFormatName:self.formatName];
}

- (void)updateWithImageEntity:(id<FICEntity>)entity formatName:(NSString *)formatName placeholder:(UIImage *)placeholder {
    self.entity = entity;
    self.formatName = formatName;
    [self.image setImageEntity:entity formatName:formatName placeholder:placeholder];
}

@end
