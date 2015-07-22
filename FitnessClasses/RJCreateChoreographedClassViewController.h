//
//  RJCreateChoreographedClassViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RJCreateChoreographedClassViewControllerSection) {
    kRJCreateChoreographedClassViewControllerSectionName,
    kRJCreateChoreographedClassViewControllerSectionInstructor,
    kRJCreateChoreographedClassViewControllerSectionCategory,
    kRJCreateChoreographedClassViewControllerSectionCreate,
    kRJCreateChoreographedClassViewControllerSectionAddTrack,
    kRJCreateChoreographedClassViewControllerSectionAddExerciseInstruction,
    kRJCreateChoreographedClassViewControllerSectionTracks,
    kRJCreateChoreographedClassViewControllerSectionExerciseInstructions,
    kNumRJCreateChoreographedClassViewControllerSections
};


@interface RJCreateChoreographedClassViewController : UICollectionViewController

@property (nonatomic, strong, readonly) NSMutableArray *exerciseInstructions;
@property (nonatomic, strong, readonly) NSMutableArray *tracks;

@end
