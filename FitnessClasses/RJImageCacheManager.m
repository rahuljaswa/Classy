//
//  RJImageCacheManager.m
//  Community
//

#import "RJAssetImageCacheEntity.h"
#import "RJClassImageCacheEntity.h"
#import "RJExerciseStepImageCacheEntity.h"
#import "RJImageCacheManager.h"
#import "RJTrackImageCacheEntity.h"
#import "RJUserImageCacheEntity.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <FastImageCache/FICImageFormat.h>


@implementation RJImageCacheManager

#pragma mark - Public Protocols - FICImageCacheDelegate

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        operation.securityPolicy.allowInvalidCertificates = YES;
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(responseObject);
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error fetching image: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil);
            });
        }];
        
        [operation start];
    });
}

#pragma mark - Public Class Methods

+ (NSArray *)formats {
    FICImageFormat *format1 = [[FICImageFormat alloc] init];
    format1.name = kRJClassImageFormatCard16BitBGR;
    format1.family = kRJImageFormatFamilyClass;
    format1.style = FICImageFormatStyle32BitBGRA;
    format1.imageSize = kRJClassImageSizeCard;
    format1.maximumCount = 250;
    format1.devices = FICImageFormatDevicePhone;
    format1.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format2 = [[FICImageFormat alloc] init];
    format2.name = kRJClassImageFormatCardSquare16BitBGR;
    format2.family = kRJImageFormatFamilyClass;
    format2.style = FICImageFormatStyle32BitBGRA;
    format2.imageSize = kRJClassImageSizeCard;
    format2.maximumCount = 250;
    format2.devices = FICImageFormatDevicePhone;
    format2.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format3 = [[FICImageFormat alloc] init];
    format3.name = kRJTrackImageFormatCard16BitBGR;
    format3.family = kRJImageFormatFamilyTrack;
    format3.style = FICImageFormatStyle32BitBGRA;
    format3.imageSize = kRJTrackImageSizeCard;
    format3.maximumCount = 250;
    format3.devices = FICImageFormatDevicePhone;
    format3.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format4 = [[FICImageFormat alloc] init];
    format4.name = kRJTrackImageFormatCardSquare16BitBGR;
    format4.family = kRJImageFormatFamilyTrack;
    format4.style = FICImageFormatStyle32BitBGRA;
    format4.imageSize = kRJTrackImageSizeCard;
    format4.maximumCount = 250;
    format4.devices = FICImageFormatDevicePhone;
    format4.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format5 = [[FICImageFormat alloc] init];
    format5.name = kRJUserImageFormatCard16BitBGR40x40;
    format5.family = kRJImageFormatFamilyUser;
    format5.style = FICImageFormatStyle32BitBGRA;
    format5.imageSize = kRJUserImageSize40x40;
    format5.maximumCount = 250;
    format5.devices = FICImageFormatDevicePhone;
    format5.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format6 = [[FICImageFormat alloc] init];
    format6.name = kRJUserImageFormatCard16BitBGR80x80;
    format6.family = kRJImageFormatFamilyUser;
    format6.style = FICImageFormatStyle32BitBGRA;
    format6.imageSize = kRJUserImageSize80x80;
    format6.maximumCount = 250;
    format6.devices = FICImageFormatDevicePhone;
    format6.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format7 = [[FICImageFormat alloc] init];
    format7.name = kRJExerciseStepImageFormatFullScreen16BitBGR;
    format7.family = kRJImageFormatFamilyExerciseStep;
    format7.style = FICImageFormatStyle32BitBGRA;
    format7.imageSize = [UIScreen mainScreen].bounds.size;
    format7.maximumCount = 500;
    format7.devices = FICImageFormatDevicePhone;
    format7.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format8 = [[FICImageFormat alloc] init];
    format8.name = kRJAssetImageFormatAppIcon;
    format8.family = kRJImageFormatFamilyAsset;
    format8.style = FICImageFormatStyle32BitBGRA;
    format8.imageSize = kRJAssetImageSizeAppIcon;
    format8.maximumCount = 1;
    format8.devices = FICImageFormatDevicePhone;
    format8.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format9 = [[FICImageFormat alloc] init];
    format9.name = kRJAssetImageFormatCreator;
    format9.family = kRJImageFormatFamilyAsset;
    format9.style = FICImageFormatStyle32BitBGRA;
    format9.imageSize = kRJAssetImageSizeCreator;
    format9.maximumCount = 1;
    format9.devices = FICImageFormatDevicePhone;
    format9.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    FICImageFormat *format10 = [[FICImageFormat alloc] init];
    format10.name = kRJAssetImageFormatWordmark;
    format10.family = kRJImageFormatFamilyAsset;
    format10.style = FICImageFormatStyle32BitBGRA;
    format10.imageSize = kRJAssetImageSizeWordmark;
    format10.maximumCount = 1;
    format10.devices = FICImageFormatDevicePhone;
    format10.protectionMode = FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication;
    
    return @[format1, format2, format3, format4, format5, format6, format7, format8, format9, format10];
}

@end
