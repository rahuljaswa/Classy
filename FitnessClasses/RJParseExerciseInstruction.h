//
//  RJParseExerciseInstruction.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>


@class RJParseExercise;

@interface RJParseExerciseInstruction : PFObject  <PFSubclassing>

@property (nonatomic, strong) NSString *advancedQuantity;
@property (nonatomic, strong) NSString *allLevelsQuantity;
@property (nonatomic, strong) NSString *beginnerQuantity;
@property (nonatomic, strong) RJParseExercise *exercise;
@property (nonatomic, strong) NSString *instruction;
@property (nonatomic, strong) NSString *intermediateQuantity;
@property (nonatomic, strong) NSNumber *startPoint;

- (void)setRoundableStartPoint:(NSNumber *)roundableStartPoint;

@end
