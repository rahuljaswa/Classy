//
//  RJParseTemplate.m
//  Pods
//
//  Created by Rahul Jaswa on 10/20/15.
//
//

#import "RJParseTemplate.h"
#import "RJParseUtils.h"

static RJParseTemplate *_currentTemplate;

@implementation RJParseTemplate

@dynamic appIconImageURL;
@dynamic appIdentifier;
@dynamic creatorImageURL;
@dynamic downloadURL;
@dynamic name;
@dynamic owner;
@dynamic themeAccentColor;
@dynamic themeBackgroundColor;
@dynamic themeTextColor;
@dynamic themeTitleColor;
@dynamic welcomeMessage;
@dynamic wordmarkImageURL;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Template";
}

+ (RJParseTemplate *)currentTemplate {
    return _currentTemplate;
}

+ (void)loadCurrentTemplateWithCompletion:(void (^)(RJParseTemplate *, BOOL))completion {
    if (_currentTemplate) {
        if (completion) {
            completion(_currentTemplate, YES);
        }
    } else {
        [RJParseUtils fetchCurrentTemplateWithCompletion:^(RJParseTemplate *currentTemplate, BOOL fetchSuccess) {
            if (currentTemplate) {
                [self setCurrentTemplateSharedInstance:currentTemplate];
            }
            if (completion) {
                completion(_currentTemplate, fetchSuccess);
            }
        }];
    }
}

+ (void)resetCurrentTemplate {
    _currentTemplate = nil;
}

+ (void)setCurrentTemplateSharedInstance:(RJParseTemplate *)currentTemplate {
    if (currentTemplate) {
        _currentTemplate = currentTemplate;
    }
}

@end
