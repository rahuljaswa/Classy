//
//  RJParseComment.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"


@class RJParseUser;

@interface RJParseComment : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) RJParseUser *creator;
@property (nonatomic, strong) NSString *text;

@end
