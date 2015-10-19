//
//  RJParseCategory.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseCategory.h"


@implementation RJParseCategory

@dynamic appIdentifiers;
@dynamic categoryDescription;
@dynamic categoryOrder;
@dynamic classes;
@dynamic image;
@dynamic name;


#pragma mark - Public Class Methods

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Category";
}

+ (PFQuery *)query {
    PFQuery *query = [super query];
    [query whereKey:NSStringFromSelector(@selector(appIdentifiers)) equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    return query;
}

@end
