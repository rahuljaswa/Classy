//
//  RJParseLike.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@class RJParseUser;

@interface RJParseLike : PFObject <PFSubclassing>

@property (nonatomic, strong) RJParseUser *creator;

@end
