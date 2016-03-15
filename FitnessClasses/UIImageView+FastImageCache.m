//
//  UIImageView+FastImageCache.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "UIImageView+FastImageCache.h"
#import <FastImageCache/FICImageCache.h>


@implementation UIImageView (FastImageCache)

- (void)setImageEntity:(NSObject<FICEntity> *)entity formatName:(NSString *)formatName placeholder:(UIImage *)placeholder {
    FICImageCache *imageCache = [FICImageCache sharedImageCache];
    
    BOOL imageExists = [imageCache imageExistsForEntity:entity withFormatName:formatName];
    if (!imageExists) {
        self.image = placeholder;
    }
    
    __weak __typeof(self) weakSelf = self;
    void (^block)(id<FICEntity>, NSString *, UIImage *) = ^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.image = image;
            if (!imageExists) {
                [strongSelf.layer addAnimation:[CATransition animation] forKey:kCATransition];
            }
            
        }
    };
    
    [imageCache retrieveImageForEntity:entity withFormatName:formatName completionBlock:block];
}

- (void)setTintableImageEntity:(NSObject<FICEntity> *)entity formatName:(NSString *)formatName placeholder:(UIImage *)placeholder {
    FICImageCache *imageCache = [FICImageCache sharedImageCache];
    
    BOOL imageExists = [imageCache imageExistsForEntity:entity withFormatName:formatName];
    if (!imageExists) {
        self.image = placeholder;
    }
    
    __weak __typeof(self) weakSelf = self;
    void (^block)(id<FICEntity>, NSString *, UIImage *) = ^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            if (!imageExists) {
                [strongSelf.layer addAnimation:[CATransition animation] forKey:kCATransition];
            }
            
        }
    };
    
    [imageCache retrieveImageForEntity:entity withFormatName:formatName completionBlock:block];
}

@end
