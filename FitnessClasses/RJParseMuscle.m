//
//  RJParseMuscle.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseMuscle.h"


@implementation RJParseMuscle

@dynamic name;

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Muscle";
}

@end
