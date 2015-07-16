//
//  RJUserDefaults.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/15/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJUserDefaults.h"

static NSString *const kRJUserDefaultsHasShownTutorialKey = @"RJUserDefaultsHasShownTutorialKey";


@implementation RJUserDefaults

+ (void)saveDidShowTutorial {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kRJUserDefaultsHasShownTutorialKey];
}

+ (BOOL)shouldShowTutorialOnLaunch {
    NSNumber *hasShownTutorial = [[NSUserDefaults standardUserDefaults] objectForKey:kRJUserDefaultsHasShownTutorialKey];
    return (!hasShownTutorial || ![hasShownTutorial boolValue]);
}

@end
