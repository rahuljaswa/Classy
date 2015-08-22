//
//  RJParseUtils.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJCreditsHelper.h"
#import "RJParseCategory.h"
#import "RJParseClass.h"
#import <Foundation/Foundation.h>


@class RJParseCategory;
@class RJParseClass;
@class RJParseExerciseEquipment;
@class RJParseUser;

@interface RJParseUtils : NSObject

+ (void)completeEarnCreditsOption:(RJCreditsHelperEarnCreditsOption)option completion:(void (^)(BOOL success))completion;

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

+ (void)incrementCreditsAvailableForUser:(RJParseUser *)user byNumber:(NSNumber *)number completion:(void (^)(BOOL success))completion;
+ (void)incrementCreditPurchasesForUser:(RJParseUser *)user forCreditsPurchased:(NSNumber *)creditsPurchased completion:(void (^)(BOOL success))completion;
+ (void)incrementPlaysForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;
+ (void)incrementTipsForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;
+ (void)incrementTipsForUser:(RJParseUser *)user completion:(void (^)(BOOL success))completion;

+ (void)insertCommentForClass:(RJParseClass *)klass text:(NSString *)text completion:(void (^)(BOOL success))completion;

+ (void)purchaseClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;

@end
