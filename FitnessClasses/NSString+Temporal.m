//
//  NSString+Temporal.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/8/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"


@implementation NSString (Temporal)

+ (NSString *)hhmmaaForTotalSeconds:(NSUInteger)totalSeconds {
    NSUInteger secondsInHour = 3600;
    
    NSUInteger hours, minutes, seconds;
    hours = totalSeconds / secondsInHour;
    minutes = (totalSeconds % secondsInHour) / 60;
    seconds = (totalSeconds % secondsInHour) % 60;
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)hours, (unsigned long)minutes, (unsigned long)seconds];
}

@end
