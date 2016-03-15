//
//  RJTouchposeApplication.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJTouchposeApplication.h"


@implementation RJTouchposeApplication

- (instancetype)init {
    self = [super init];
    if (self) {
        self.alwaysShowTouches = YES;
    }
    return self;
}

@end
