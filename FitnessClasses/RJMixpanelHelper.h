//
//  RJMixpanelHelper.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/3/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mixpanel/Mixpanel.h>

FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsToken;

// People
FOUNDATION_EXPORT NSString *const kRJMixpanelPeopleConstantsAppOpens;
FOUNDATION_EXPORT NSString *const kRJMixpanelPeopleConstantsPlays;

// Generic
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsOpenedApp;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsPlayedClass;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsPlayedClassClassNameDictionaryKey;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsPlayedClassClassObjectIDDictionaryKey;

// Sharing
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsClickedTwitterShareButton;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsClickedMessagesShareButton;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsClickedEmailShareButton;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsSharedViaTwitter;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsSharedViaMessages;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsSharedViaEmail;

// Subscribing
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsViewedSubscriptionPage;
FOUNDATION_EXPORT NSString *const kRJMixpanelConstantsSubscribed;


@interface RJMixpanelHelper : Mixpanel

+ (void)trackForCurrentApp:(NSString *)event;
+ (void)trackForCurrentApp:(NSString *)event properties:(NSDictionary *)properties;

@end
