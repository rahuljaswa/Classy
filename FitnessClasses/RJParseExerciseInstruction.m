//
//  RJParseExerciseInstruction.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseExerciseInstruction.h"


@implementation RJParseExerciseInstruction

@dynamic advancedQuantity;
@dynamic allLevelsQuantity;
@dynamic beginnerQuantity;
@dynamic exercise;
@dynamic instruction;
@dynamic intermediateQuantity;
@dynamic startPoint;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"ExerciseInstruction";
}

@end
