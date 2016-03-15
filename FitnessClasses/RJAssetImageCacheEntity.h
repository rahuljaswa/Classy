//
//  RJAssetImageCacheEntity.h
//  Pods
//
//  Created by Rahul Jaswa on 11/3/15.
//
//

#import <FastImageCache/FICEntity.h>
#import <CoreGraphics/CoreGraphics.h>

FOUNDATION_EXPORT NSString *const kRJImageFormatFamilyAsset;

FOUNDATION_EXPORT NSString *const kRJAssetImageFormatAppIcon;
FOUNDATION_EXPORT NSString *const kRJAssetImageFormatCreator;
FOUNDATION_EXPORT NSString *const kRJAssetImageFormatWordmark;

FOUNDATION_EXPORT CGSize const kRJAssetImageSizeAppIcon;
FOUNDATION_EXPORT CGSize const kRJAssetImageSizeCreator;
FOUNDATION_EXPORT CGSize const kRJAssetImageSizeWordmark;


@interface RJAssetImageCacheEntity : NSObject <FICEntity>

- (instancetype)initWithAssetImageURL:(NSURL *)imageURL;

@end
