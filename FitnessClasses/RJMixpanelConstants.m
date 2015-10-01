//
//  RJMixpanelConstants.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/3/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJMixpanelConstants.h"

#ifdef DEBUG
    NSString *const kRJMixpanelConstantsToken = @"ba20bec098cd9cfea000bddd51aa9362";
#else
    NSString *const kRJMixpanelConstantsToken = @"04945846b9530cdd3237ea1e68141d8b";
#endif

// People
NSString *const kRJMixpanelPeopleConstantsAppOpens = @"App Opens";
NSString *const kRJMixpanelPeopleConstantsPlays = @"Plays";

// Generic
NSString *const kRJMixpanelConstantsOpenedApp = @"Opened App";
NSString *const kRJMixpanelConstantsPlayedClass = @"Played Class";
NSString *const kRJMixpanelConstantsPlayedClassClassNameDictionaryKey = @"Class Name";
NSString *const kRJMixpanelConstantsPlayedClassClassObjectIDDictionaryKey = @"Class ObjectID";

// Sharing
NSString *const kRJMixpanelConstantsClickedTwitterShareButton = @"Clicked Twitter Share Button";
NSString *const kRJMixpanelConstantsClickedMessagesShareButton = @"Clicked Messages Share Button";
NSString *const kRJMixpanelConstantsClickedEmailShareButton = @"Clicked Email Share Button";
NSString *const kRJMixpanelConstantsSharedViaTwitter = @"Shared Via Twitter";
NSString *const kRJMixpanelConstantsSharedViaMessages = @"Shared Via Messages";
NSString *const kRJMixpanelConstantsSharedViaEmail = @"Shared Via Email";


@implementation RJMixpanelConstants

@end
