//
//  RJParseComment.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComment.h"


@implementation RJParseComment

@dynamic createdAt;
@dynamic creator;
@dynamic text;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Comment";
}

@end
