//
//  RJParseCategory.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@interface RJParseCategory : PFObject <PFSubclassing>

@property (nonatomic, strong) PFRelation *classes;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *name;

@end
