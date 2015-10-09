//
//  RJParseExerciseStep.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"


@interface RJParseExerciseStep : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *textDescription;

@end
