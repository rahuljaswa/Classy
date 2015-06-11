//
//  RJParseCategory.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseCategory.h"


@implementation RJParseCategory

@dynamic classes;
@dynamic image;
@dynamic name;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Category";
}

@end
