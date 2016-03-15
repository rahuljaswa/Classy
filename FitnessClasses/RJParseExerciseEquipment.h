//
//  RJParseExerciseEquipment.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/16/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"


@interface RJParseExerciseEquipment : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) NSString *name;

@end
