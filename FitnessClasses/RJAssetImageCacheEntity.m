//
//  RJAssetImageCacheEntity.m
//  Pods
//
//  Created by Rahul Jaswa on 11/3/15.
//
//

#import "RJAssetImageCacheEntity.h"
#import <FastImageCache/FICUtilities.h>

NSString *const kRJImageFormatFamilyAsset = @"kRJImageFormatFamilyAsset";

NSString *const kRJAssetImageFormatAppIcon = @"RJAssetImageFormatAppIcon";
NSString *const kRJAssetImageFormatCreator = @"RJAssetImageFormatCreator";
NSString *const kRJAssetImageFormatWordmark = @"RJAssetImageFormatWordmark";

CGSize const kRJAssetImageSizeAppIcon = { 150, 150 };
CGSize const kRJAssetImageSizeCreator = { 300, 300 };
CGSize const kRJAssetImageSizeWordmark = { 400, 115 };


@interface RJAssetImageCacheEntity ()

@property (strong, nonatomic, readonly) NSURL *imageURL;
@property (strong, nonatomic, readonly) NSString *objectID;

@end


@implementation RJAssetImageCacheEntity

@synthesize imageURL = _imageURL;
@synthesize objectID = _objectID;
@synthesize sourceImageUUID = _sourceImageUUID;
@synthesize UUID = _UUID;

#pragma mark - Public Protocols - FICEntity

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(context, contextBounds);
        
        CGFloat newWidth;
        CGFloat newHeight;
        
        if (image.size.width <= image.size.height) {
            newHeight = contextSize.height;
            newWidth = ((newHeight/image.size.height) * image.size.width);
        } else {
            newWidth = contextSize.width;
            newHeight = ((newWidth/image.size.width) * image.size.height);
        }
        
        CGFloat newX = (CGRectGetWidth(contextBounds)/2.0f - newWidth/2.0f);
        CGFloat newY = (CGRectGetHeight(contextBounds)/2.0f - newHeight/2.0f);
        
        UIGraphicsPushContext(context);
        [image drawInRect:CGRectMake(newX, newY, newWidth, newHeight)];
        UIGraphicsPopContext();
    };
    
    return drawingBlock;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    return self.imageURL;
}

- (NSString *)sourceImageUUID {
    if (!_sourceImageUUID) {
        CFUUIDBytes sourceImageUUIDBytes;
        sourceImageUUIDBytes = FICUUIDBytesFromMD5HashOfString([self.imageURL absoluteString]);
        _sourceImageUUID = FICStringWithUUIDBytes(sourceImageUUIDBytes);
    }
    return _sourceImageUUID;
}

- (NSString *)UUID {
    if (!_UUID) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(self.objectID);
        _UUID = FICStringWithUUIDBytes(UUIDBytes);
    }
    return _UUID;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithAssetImageURL:(NSURL *)imageURL {
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        _objectID = [imageURL absoluteString];
    }
    return self;
}

@end
