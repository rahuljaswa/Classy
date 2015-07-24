//
//  RJParseUtils.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseCategory.h"
#import "RJParseClass.h"
#import "RJParseComment.h"
#import "RJParseExercise.h"
#import "RJParseLike.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import <Parse/Parse.h>


@implementation RJParseUtils

#pragma mark - Private Class Methods

+ (void)updateClassQueryWithIncludedKeys:(PFQuery *)query {
    [query includeKey:@"exerciseInstructions"];
    [query includeKey:@"exerciseInstructions.exercise"];
    [query includeKey:@"exerciseInstructions.exercise.steps"];
    [query includeKey:@"tracks"];
    [query includeKey:@"instructionQueue"];
    [query includeKey:@"category"];
    [query includeKey:@"instructor"];
    [query includeKey:@"comments"];
    [query includeKey:@"comments.creator"];
    [query includeKey:@"likes"];
    [query includeKey:@"likes.creator"];
}

#pragma mark - Public Class Methods - Credit Earning

+ (void)completeEarnCreditsOption:(RJCreditsHelperEarnCreditsOption)option completion:(void (^)(BOOL))completion {
    RJParseUser *user = [RJParseUser currentUser];
    
    NSNumber *creditsEarned = nil;
    switch (option) {
        case kRJCreditsHelperEarnCreditsOptionAppStoreReview:
            creditsEarned = @2;
            [user addUniqueObject:[NSDate date] forKey:@"appStoreCreditEarnDates"];
            break;
        case kRJCreditsHelperEarnCreditsOptionFacebookShare:
            creditsEarned = @1;
            [user addUniqueObject:[NSDate date] forKey:@"facebookCreditEarnDates"];
            break;
        case kRJCreditsHelperEarnCreditsOptionTwitterShare:
            creditsEarned = @1;
            [user addUniqueObject:[NSDate date] forKey:@"twitterCreditEarnDates"];
            break;
    }
    
    [user incrementKey:@"creditsAvailable" byAmount:creditsEarned];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error updating user earn dates\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

#pragma mark - Public Class Methods - Creating

+ (void)createExerciseWithName:(NSString *)name primaryEquipment:(RJParseExerciseEquipment *)primaryEquipment primaryMuscles:(NSArray *)primaryMuscles secondaryMuscles:(NSArray *)secondaryMuscles completion:(void (^)(BOOL))completion {
    RJParseExercise *exercise = [RJParseExercise object];
    exercise.title = name;
    exercise.primaryEquipment = primaryEquipment;
    exercise.primaryMuscles = primaryMuscles;
    exercise.secondaryMuscles = secondaryMuscles;
    [exercise saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error creating exercise\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

+ (void)createClassWithName:(NSString *)name classType:(RJParseClassType)classType category:(RJParseCategory *)category instructor:(RJParseUser *)instructor tracks:(NSArray *)tracks exerciseInstructions:(NSArray *)exerciseInstructions completion:(void (^)(BOOL))completion {
    RJParseClass *class = [RJParseClass object];
    class.classType = @(classType);
    class.instructor = instructor;
    class.name = name;
    class.category = category;
    class.tracks = tracks;
    class.exerciseInstructions = exerciseInstructions;
    [class saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error creating class\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

#pragma mark - Public Class Methods - Updating

+ (void)updateClass:(RJParseClass *)klass withName:(NSString *)name classType:(RJParseClassType)classType category:(RJParseCategory *)category instructor:(RJParseUser *)instructor tracks:(NSArray *)tracks exerciseInstructions:(NSArray *)exerciseInstructions completion:(void (^)(BOOL))completion {
    klass.classType = @(classType);
    klass.instructor = instructor;
    klass.name = name;
    klass.category = category;
    klass.tracks = tracks;
    klass.exerciseInstructions = exerciseInstructions;
    [klass saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error updating class\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

#pragma mark - Public Class Methods - Fetching

+ (void)fetchAllCategoriesWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all categories\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchAllInstructorsWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"instructor" equalTo:@(YES)];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all instructors\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchAllEquipmentWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"ExerciseEquipment"];
    [query orderByDescending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all equipment\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchAllExercisesWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Exercise"];
    [query orderByDescending:@"title"];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all exercises\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchAllMusclesWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Muscle"];
    [query orderByDescending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all muscles\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchClassesForCategory:(RJParseCategory *)category completion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Class"];
    [query whereKey:@"category" equalTo:category];
    [self updateClassQueryWithIncludedKeys:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching classes for category '%@'\n\n%@", category.name, [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchClassesForInstructor:(RJParseUser *)instructor completion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Class"];
    [self updateClassQueryWithIncludedKeys:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching classes for instructor '%@'\n\n%@", instructor.name, [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchClassWithId:(NSString *)objectId completion:(void (^)(RJParseClass *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Class"];
    [self updateClassQueryWithIncludedKeys:query];
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"Error fetching class with objectId\n\n%@", objectId);
        }
        if (completion) {
            completion((RJParseClass *)object);
        }
    }];
}

+ (void)fetchNewClassesForCategoryType:(RJParseCategoryType)categoryType withCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Class"];
    [self updateClassQueryWithIncludedKeys:query];
    if (categoryType == kRJParseCategoryTypeNone) {
        PFQuery *subquery = [PFQuery queryWithClassName:@"Category"];
        [subquery whereKeyDoesNotExist:@"categoryType"];
        [query whereKey:@"category" matchesQuery:subquery];
    } else {
        PFQuery *subquery = [PFQuery queryWithClassName:@"Category"];
        [subquery whereKey:@"categoryType" equalTo:@(categoryType)];
        [query whereKey:@"category" matchesQuery:subquery];
    }
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all classes\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchPopularClassesForCategoryType:(RJParseCategoryType)categoryType withCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Class"];
    [self updateClassQueryWithIncludedKeys:query];
    [query orderByDescending:@"plays"];
    if (categoryType == kRJParseCategoryTypeNone) {
        PFQuery *subquery = [PFQuery queryWithClassName:@"Category"];
        [subquery whereKeyDoesNotExist:@"categoryType"];
        [query whereKey:@"category" matchesQuery:subquery];
    } else {
        PFQuery *subquery = [PFQuery queryWithClassName:@"Category"];
        [subquery whereKey:@"categoryType" equalTo:@(categoryType)];
        [query whereKey:@"category" matchesQuery:subquery];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all classes\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

#pragma mark - Public Class Methods - Updating

+ (void)incrementCreditsAvailableForUser:(RJParseUser *)user byNumber:(NSNumber *)number completion:(void (^)(BOOL))completion {
    [user incrementKey:@"creditsAvailable" byAmount:number];
    [user saveEventually:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error incrementing creditPurchases for '%@'\n\n%@", user.name, [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

+ (void)incrementCreditPurchasesForUser:(RJParseUser *)user forCreditsPurchased:(NSNumber *)creditsPurchased completion:(void (^)(BOOL))completion {
    [user incrementKey:@"creditPurchases"];
    [self incrementCreditsAvailableForUser:user byNumber:creditsPurchased completion:completion];
}

+ (void)incrementPlaysForClass:(RJParseClass *)klass completion:(void (^)(BOOL))completion {
    [klass incrementKey:@"plays"];
    [klass saveEventually:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error incrementing plays for '%@'\n\n%@", klass.name, [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

+ (void)incrementTipsForClass:(RJParseClass *)klass completion:(void (^)(BOOL))completion {
    [klass incrementKey:@"tips"];
    [klass saveEventually:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error incrementing tips for '%@'\n\n%@", klass.name, [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

+ (void)incrementTipsForUser:(RJParseUser *)user completion:(void (^)(BOOL))completion {
    [user incrementKey:@"tips"];
    [user saveEventually:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error incrementing tips for '%@'\n\n%@", user.name, [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

#pragma mark - Public Class Methods - Likes/Comments

+ (void)insertCommentForClass:(RJParseClass *)klass text:(NSString *)text completion:(void (^)(BOOL))completion {
    RJParseComment *comment = [RJParseComment object];
    comment.text = text;
    comment.creator = [RJParseUser currentUser];
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [klass addUniqueObject:comment forKey:@"comments"];
            [klass saveEventually:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@"Error inserting comment for '%@'\n\n%@", klass.name, [error localizedDescription]);
                }
                if (completion) {
                    completion(succeeded);
                }
            }];
        } else {
            NSLog(@"Error creating comment for '%@'\n\n%@", klass.name, [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        }
    }];
}

+ (void)insertLikeForClass:(RJParseClass *)klass completion:(void (^)(BOOL))completion {
    RJParseLike *like = [RJParseLike object];
    like.creator = [RJParseUser currentUser];
    [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [klass addUniqueObject:like forKey:@"likes"];
            [klass saveEventually:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@"Error inserting like for '%@'\n\n%@", klass.name, [error localizedDescription]);
                }
                if (completion) {
                    completion(succeeded);
                }
            }];
        } else {
            NSLog(@"Error creating like for '%@'\n\n%@", klass.name, [error localizedDescription]);
            if (completion) {
                completion(NO);
            }
        }
    }];
}

#pragma mark - Public Class Methods - Purchasing

+ (void)purchaseClass:(RJParseClass *)klass completion:(void (^)(BOOL))completion {
    RJParseUser *user = [RJParseUser currentUser];
    NSUInteger creditsAvailable = [user.creditsAvailable unsignedIntegerValue];
    NSUInteger creditsCost = [klass.creditsCost unsignedIntegerValue];
    if (creditsAvailable >= creditsCost) {
        user.creditsAvailable = @(creditsAvailable - creditsCost);
        [user addUniqueObject:klass forKey:@"classesPurchased"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                NSLog(@"Error purchasing '%@'\n\n%@", klass.name, [error localizedDescription]);
            }
            if (completion) {
                completion(succeeded);
            }
        }];
    } else if (completion) {
        completion(NO);
    }
}

@end
