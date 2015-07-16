//
//  RJUserDefaults.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/15/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RJUserDefaults : NSObject

+ (void)saveDidShowTutorial;
+ (BOOL)shouldShowTutorialOnLaunch;

@end
