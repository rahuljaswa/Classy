//
//  RJParseExerciseStep.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseExerciseStep.h"


@implementation RJParseExerciseStep

@dynamic image;
@dynamic textDescription;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"ExerciseStep";
}

@end
