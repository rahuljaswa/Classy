//
//  RJTrackImageCacheEntity.h
//  Community
//

#import <FastImageCache/FICEntity.h>
@import CoreGraphics;
@import Foundation;

FOUNDATION_EXPORT NSString *const kRJImageFormatFamilyTrack;
FOUNDATION_EXPORT NSString *const kRJTrackImageFormatCardSquare16BitBGR;
FOUNDATION_EXPORT NSString *const kRJTrackImageFormatCard16BitBGR;
FOUNDATION_EXPORT CGSize const kRJTrackImageSizeCard;


@interface RJTrackImageCacheEntity : NSObject <FICEntity>

- (instancetype)initWithTrackImageURL:(NSURL *)imageURL objectID:(NSString *)objectID;

@end
