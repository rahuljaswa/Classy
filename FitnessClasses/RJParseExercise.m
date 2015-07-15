//
//  RJParseExercise.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseExercise.h"


@implementation RJParseExercise

@dynamic image;
@dynamic steps;
@dynamic title;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Exercise";
}

@end
