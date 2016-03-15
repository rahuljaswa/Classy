//
//  RJParseComparablePFObject.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 10/8/15.
//  Copyright © 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"


@implementation RJParseComparablePFObject

- (NSUInteger)hash {
    return [self.objectId hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) { return YES; }
    if ([object class] != [self class]) { return NO; }
    PFObject *otherPFObject = (PFObject *)object;
    return [self.objectId isEqualToString:otherPFObject.objectId];
}

@end
