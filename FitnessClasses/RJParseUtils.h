//
//  RJParseUtils.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJInAppPurchaseHelper.h"
#import "RJParseCategory.h"
#import "RJParseClass.h"
#import <Foundation/Foundation.h>


@class RJParseCategory;
@class RJParseClass;
@class RJParseExerciseEquipment;
@class RJParseKey;
@class RJParseUser;

@interface RJParseUtils : NSObject

+ (void)completeEarnBonusOption:(RJInAppPurchaseHelperBonusOption)option completion:(void (^)(BOOL success))completion;

+ (void)createCategoryWithName:(NSString *)name completion:(void (^)(BOOL))completion;
+ (void)createExerciseWithName:(NSString *)name primaryEquipment:(RJParseExerciseEquipment *)primaryEquipment primaryMuscles:(NSArray *)primaryMuscles secondaryMuscles:(NSArray *)secondaryMuscles completion:(void (^)(BOOL success))completion;
+ (void)createClassWithName:(NSString *)name classType:(RJParseClassType)classType category:(RJParseCategory *)category instructor:(RJParseUser *)instructor tracks:(NSArray *)tracks exerciseInstructions:(NSArray *)exerciseInstructions completion:(void (^)(BOOL))completion;
+ (void)createInstructorWithName:(NSString *)name completion:(void (^)(BOOL))completion;

+ (void)updateClass:(RJParseClass *)klass withName:(NSString *)name classType:(RJParseClassType)classType category:(RJParseCategory *)category instructor:(RJParseUser *)instructor tracks:(NSArray *)tracks exerciseInstructions:(NSArray *)exerciseInstructions completion:(void (^)(BOOL))completion;

+ (void)fetchAllCategoriesWithCompletion:(void (^)(NSArray *categories))completion;
+ (void)fetchAllInstructorsWithCompletion:(void (^)(NSArray *instructors))completion;
+ (void)fetchAllEquipmentWithCompletion:(void (^)(NSArray *equipment))completion;
+ (void)fetchAllExercisesForPrimaryEquipment:(RJParseExerciseEquipment *)primaryEquipment completion:(void (^)(NSArray *exercises))completion;
+ (void)fetchAllExercisesWithCompletion:(void (^)(NSArray *exercises))completion;
+ (void)fetchAllMusclesWithCompletion:(void (^)(NSArray *muscles))completion;
+ (void)fetchClassesForCategory:(RJParseCategory *)category completion:(void (^)(NSArray *classes))completion;
+ (void)fetchClassesForInstructor:(RJParseUser *)instructor completion:(void (^)(NSArray *classes))completion;
+ (void)fetchClassWithId:(NSString *)objectId completion:(void (^)(RJParseClass *klass))completion;
+ (void)fetchCurrentUserWithCompletion:(void (^)(RJParseUser *user))completion;
+ (void)fetchKeyForIdentifier:(NSString *)identifier completion:(void (^)(RJParseKey *key))completion;

+ (void)incrementPlaysForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;
+ (void)incrementTipsForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;
+ (void)incrementTipsForUser:(RJParseUser *)user completion:(void (^)(BOOL success))completion;

+ (void)insertCommentForClass:(RJParseClass *)klass text:(NSString *)text completion:(void (^)(BOOL success))completion;

@end
