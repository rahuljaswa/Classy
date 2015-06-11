//
//  RJParseLike.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseLike.h"


@implementation RJParseLike

@dynamic creator;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Like";
}

@end
