//
//  RJParseTemplate.h
//  Pods
//
//  Created by Rahul Jaswa on 10/20/15.
//
//

#import "RJParseComparablePFObject.h"


@class RJParseUser;

@interface RJParseTemplate : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) NSString *appIconImageURL;
@property (nonatomic, strong) NSString *appIdentifier;
@property (nonatomic, strong) NSString *creatorImageURL;
@property (nonatomic, strong) NSString *downloadURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) RJParseUser *owner;
@property (nonatomic, strong) NSString *themeAccentColor;
@property (nonatomic, strong) NSString *themeBackgroundColor;
@property (nonatomic, strong) NSString *themeTextColor;
@property (nonatomic, strong) NSString *themeTitleColor;
@property (nonatomic, strong) NSString *welcomeMessage;
@property (nonatomic, strong) NSString *wordmarkImageURL;

+ (RJParseTemplate *)currentTemplate;
+ (void)loadCurrentTemplateWithCompletion:(void (^)(RJParseTemplate *currentTemplate, BOOL fetchSuccess))completion;
+ (void)resetCurrentTemplate;
+ (void)setCurrentTemplateSharedInstance:(RJParseTemplate *)currentTemplate;

@end
