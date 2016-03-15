//
//  RJImageCacheManager.h
//  Community
//

#import <FastImageCache/FICImageCache.h>


@interface RJImageCacheManager : NSObject <FICImageCacheDelegate>

+ (NSArray *)formats;

@end
