//
//  RJParseExercise.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@class RJParseExerciseEquipment;

@interface RJParseExercise : PFObject <PFSubclassing>

@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) RJParseExerciseEquipment *primaryEquipment;
@property (nonatomic, strong) NSArray *primaryMuscles;
@property (nonatomic, strong) NSArray *secondaryMuscles;
@property (nonatomic, strong) NSArray *steps;
@property (nonatomic, strong) NSString *title;

@end
