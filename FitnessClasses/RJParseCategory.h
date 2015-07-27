//
//  RJParseCategory.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>

typedef NS_ENUM(NSInteger, RJParseCategoryType) {
    kRJParseCategoryTypeNone = -1,
    kRJParseCategoryTypeDropIn,
    kRJParseCategoryTypeProgram,
    kNumRJParseCategoryTypes
};


@interface RJParseCategory : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *categoryDescription;
@property (nonatomic, strong) NSNumber *categoryType;
@property (nonatomic, strong) PFRelation *classes;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) RJParseCategoryType formattedCategoryType;

@end
