//
//  RJParseCategory.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseCategory.h"


@implementation RJParseCategory

@dynamic categoryType;
@dynamic classes;
@dynamic image;
@dynamic name;

@synthesize formattedCategoryType;

#pragma mark - Public Getters

- (RJParseCategoryType)formattedCategoryType {
    if (self.categoryType) {
        return (RJParseCategoryType)[self.categoryType integerValue];
    } else {
        return kRJParseCategoryTypeNone;
    }
}

#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Category";
}

@end
