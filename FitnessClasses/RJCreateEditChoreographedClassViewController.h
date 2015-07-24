//
//  RJCreateEditChoreographedClassViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RJCreateEditChoreographedClassViewControllerSection) {
    kRJCreateEditChoreographedClassViewControllerSectionName,
    kRJCreateEditChoreographedClassViewControllerSectionInstructor,
    kRJCreateEditChoreographedClassViewControllerSectionCategory,
    kRJCreateEditChoreographedClassViewControllerSectionCreate,
    kRJCreateEditChoreographedClassViewControllerSectionAddTrack,
    kRJCreateEditChoreographedClassViewControllerSectionAddExerciseInstruction,
    kRJCreateEditChoreographedClassViewControllerSectionTracks,
    kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions,
    kNumRJCreateEditChoreographedClassViewControllerSections
};


@class RJParseClass;

@interface RJCreateEditChoreographedClassViewController : UICollectionViewController

@property (nonatomic, strong) RJParseClass *klass;

@property (nonatomic, strong, readonly) NSMutableArray *exerciseInstructions;
@property (nonatomic, strong, readonly) NSMutableArray *tracks;

@end
