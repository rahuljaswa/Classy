//
//  RJArithmeticHelper.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJArithmeticHelper.h"

@implementation RJArithmeticHelper

+ (void)extractHours:(NSInteger *)hours minutes:(NSInteger *)minutes seconds:(NSInteger *)seconds forLength:(NSInteger)length {
    *hours = length/3600;
    *minutes = (length-(*hours*3600))/60;
    *seconds = (length-((*hours*3600)+(*minutes*60)));
}

@end
