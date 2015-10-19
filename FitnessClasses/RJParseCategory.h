//
//  RJParseCategory.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"


@interface RJParseCategory : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) NSArray *appIdentifiers;
@property (nonatomic, strong) NSString *categoryDescription;
@property (nonatomic, strong) NSNumber *categoryOrder;
@property (nonatomic, strong) PFRelation *classes;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *name;

@end
