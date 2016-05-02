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
#import "RJParseExerciseEquipment.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseKey.h"
#import "RJParseLike.h"
#import "RJParseMuscle.h"
#import "RJParseTemplate.h"
#import "RJParseTrack.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJSoundCloudAPIClient.h"
#import "RJSoundCloudTrack.h"
#import <Parse/Parse.h>


@implementation RJParseUtils

#pragma mark - Private Class Methods

+ (void)updateClassQueryWithIncludedKeys:(PFQuery *)query {
    NSString *exerciseInstructions = NSStringFromSelector(@selector(exerciseInstructions));
    NSString *exercise = NSStringFromSelector(@selector(exercise));
    NSString *comments = NSStringFromSelector(@selector(comments));
    NSString *creator = NSStringFromSelector(@selector(creator));
    NSString *likes = NSStringFromSelector(@selector(likes));
    
    [query includeKey:exerciseInstructions];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", exerciseInstructions, exercise]];
    [query includeKey:[NSString stringWithFormat:@"%@.%@.%@", exerciseInstructions, exercise, NSStringFromSelector(@selector(steps))]];
    [query includeKey:NSStringFromSelector(@selector(tracks))];
    [query includeKey:NSStringFromSelector(@selector(categories))];
    [query includeKey:NSStringFromSelector(@selector(instructor))];
    [query includeKey:comments];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", comments, creator]];
    [query includeKey:likes];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", likes, creator]];
}

#pragma mark - Public Class Methods - Creating

+ (void)completeEarnBonusOption:(RJInAppPurchaseHelperBonusOption)option completion:(void (^)(BOOL success))completion {
    RJParseUser *user = [RJParseUser currentUserWithSubscriptions];
    
    NSNumber *creditsEarned = nil;
    
    switch (option) {
        case kRJInAppPurchaseHelperBonusOptionAppStoreReview:
            creditsEarned = @2;
            [user addUniqueObject:[NSDate date] forKey:NSStringFromSelector(@selector(appStoreCreditEarnDates))];
            break;
        case kRJInAppPurchaseHelperBonusOptionTwitterShare:
            creditsEarned = @1;
            [user addUniqueObject:[NSDate date] forKey:NSStringFromSelector(@selector(twitterCreditEarnDates))];
            break;
    }
    
    [user incrementKey:NSStringFromSelector(@selector(creditsAvailable)) byAmount:creditsEarned];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error updating user earn dates\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

+ (void)createCategoryWithName:(NSString *)name completion:(void (^)(BOOL))completion {
    RJParseCategory *category = [RJParseCategory object];
    category.name = name;
    [category saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error creating category\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(succeeded);
        }
    }];
}

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
    [class addUniqueObject:category forKey:NSStringFromSelector(@selector(categories))];
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

+ (void)createInstructorWithName:(NSString *)name completion:(void (^)(BOOL))completion {
    RJParseUser *instructor = [RJParseUser object];
    instructor.name = name;

    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *password = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < 10; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [password appendFormat:@"%C", c];
    }
    instructor.password = password;
    instructor.instructor = YES;
    [instructor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error creating instructor\n\n%@", [error localizedDescription]);
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
    [klass addUniqueObject:category forKey:NSStringFromSelector(@selector(categories))];
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
    PFQuery *query = [RJParseCategory query];
    [query orderByAscending:NSStringFromSelector(@selector(categoryOrder))];
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
    PFQuery *query = [RJParseUser query];
    [query whereKey:NSStringFromSelector(@selector(instructor)) equalTo:@(YES)];
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
    PFQuery *query = [RJParseExerciseEquipment query];
    [query orderByAscending:NSStringFromSelector(@selector(name))];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all equipment\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchAllExercisesForPrimaryEquipment:(RJParseExerciseEquipment *)primaryEquipment completion:(void (^)(NSArray *))completion {
    PFQuery *query = [RJParseExercise query];
    [query includeKey:NSStringFromSelector(@selector(primaryEquipment))];
    [query whereKey:NSStringFromSelector(@selector(primaryEquipment)) equalTo:primaryEquipment];
    [query orderByAscending:NSStringFromSelector(@selector(title))];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all exercises for category\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchAllExercisesWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [RJParseExercise query];
    [query orderByAscending:NSStringFromSelector(@selector(title))];
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
    PFQuery *query = [RJParseMuscle query];
    [query orderByAscending:NSStringFromSelector(@selector(name))];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all muscles\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchAllTracksWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [RJParseTrack query];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!objects) {
            NSLog(@"Error fetching all tracks\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchClassesForCategory:(RJParseCategory *)category completion:(void (^)(NSArray *))completion {
    PFQuery *query = [RJParseClass query];
    [query whereKey:NSStringFromSelector(@selector(categories)) equalTo:category];
    [query orderByAscending:NSStringFromSelector(@selector(classOrder))];
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
    PFQuery *query = [RJParseClass query];
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
    PFQuery *query = [RJParseClass query];
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

+ (void)fetchCurrentUserWithCompletion:(void (^)(RJParseUser *, BOOL))completion {
    RJParseUser *parseCurrentUser = [RJParseUser currentUser];
    if (parseCurrentUser) {
        PFQuery *query = [RJParseUser query];
        [query includeKey:NSStringFromSelector(@selector(subscriptions))];
        [query includeKey:NSStringFromSelector(@selector(twitterCreditEarnDates))];
        [query includeKey:NSStringFromSelector(@selector(facebookCreditEarnDates))];
        [query includeKey:NSStringFromSelector(@selector(appStoreCreditEarnDates))];
        [query getObjectInBackgroundWithId:parseCurrentUser.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (!object) {
                NSLog(@"Error fetching current user:\n\n%@", [error localizedDescription]);
            }
            if (completion) {
                completion((RJParseUser *)object, !error);
            }
        }];
    } else if (completion) {
        completion(nil, YES);
    }
}

+ (void)fetchCurrentTemplateWithCompletion:(void (^)(RJParseTemplate *, BOOL))completion {
    PFQuery *query = [RJParseTemplate query];
    [query whereKey:NSStringFromSelector(@selector(appIdentifier)) equalTo:[[NSBundle mainBundle] bundleIdentifier]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!objects) {
            NSLog(@"Error fetching template:\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion([objects firstObject], !error);
        }
    }];
}

+ (void)fetchKeyForIdentifier:(NSString *)identifier completion:(void (^)(RJParseKey *))completion {
    PFQuery *query = [RJParseKey query];
    [query whereKey:NSStringFromSelector(@selector(identifier)) equalTo:identifier];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!objects) {
            NSLog(@"Error fetching key for identifier:\n\n%@", identifier);
        }
        if (completion) {
            completion([objects firstObject]);
        }
    }];
}

#pragma mark - Public Class Methods - Updating

+ (void)incrementPlaysForClass:(RJParseClass *)klass completion:(void (^)(BOOL))completion {
    [klass incrementKey:NSStringFromSelector(@selector(plays))];
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
    [klass incrementKey:NSStringFromSelector(@selector(tips))];
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
    [user incrementKey:NSStringFromSelector(@selector(tips))];
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
    comment.creator = [RJParseUser currentUserWithSubscriptions];
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [klass addUniqueObject:comment forKey:NSStringFromSelector(@selector(comments))];
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

#pragma mark - Public Class Methods - Maintenance

+ (void)updateTracksMetadataWithCompletion:(void (^)(BOOL))completion {
    [self fetchAllTracksWithCompletion:^(NSArray *parseTracks) {
        if (parseTracks) {
            NSMutableString *soundCloudTrackIDs = [[NSMutableString alloc] init];
            for (RJParseTrack *parseTrack in parseTracks) {
                if ([soundCloudTrackIDs length] > 0) {
                    [soundCloudTrackIDs appendString:@","];
                }
                [soundCloudTrackIDs appendString:parseTrack.soundCloudTrackID];
            }
            [[RJSoundCloudAPIClient sharedAPIClient] getTracksWithTrackIDs:soundCloudTrackIDs completion:^(NSArray *soundCloudTracks) {
                if (soundCloudTracks) {
                    NSArray *parseTracksIDs = [parseTracks valueForKey:NSStringFromSelector(@selector(soundCloudTrackID))];
                    NSMutableArray *updatedParseTracks = [[NSMutableArray alloc] init];
                    NSInteger numberOfSoundCloudTracks = [soundCloudTracks count];
                    for (NSInteger i=0; i<numberOfSoundCloudTracks; i++) {
                        RJSoundCloudTrack *soundCloudTrack = soundCloudTracks[i];
                        NSIndexSet *indexesInParseTracks = [parseTracksIDs indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            return [obj isEqualToString:soundCloudTrack.trackID];
                        }];
                        
                        [indexesInParseTracks enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                            RJParseTrack *parseTrack = parseTracks[idx];
                            [parseTrack updateWithSoundCloudTrack:soundCloudTrack];
                            [updatedParseTracks addObject:parseTrack];
                        }];
                    }
                    
                    [PFObject saveAllInBackground:updatedParseTracks block:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            if (completion) {
                                completion(YES);
                            }
                        } else {
                            NSLog(@"Error saving updated track metadata%@", [error localizedDescription]);
                            if (completion) {
                                completion(NO);
                            }
                        }
                    }];
                } else {
                    if (completion) {
                        completion(NO);
                    }
                }
            }];
        } else {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

@end
