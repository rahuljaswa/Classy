//
//  RJExerciseEquipmentOptionsViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/30/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJGalleryViewController.h"


@class RJParseExerciseEquipment;
@class RJExerciseEquipmentOptionsViewController;

@protocol RJExerciseEquipmentOptionsViewControllerDelegate <NSObject>

- (void)exerciseEquipmentOptionsViewController:(RJExerciseEquipmentOptionsViewController *)exerciseEquipmentOptionsViewController didSelectExerciseEquipment:(RJParseExerciseEquipment *)exerciseEquipment;

@end


@interface RJExerciseEquipmentOptionsViewController : RJGalleryViewController

@property (nonatomic, assign) id<RJExerciseEquipmentOptionsViewControllerDelegate> exerciseEquipmentOptionsDelegate;
@property (nonatomic, strong) RJParseExerciseEquipment *selectedEquipment;

@end
