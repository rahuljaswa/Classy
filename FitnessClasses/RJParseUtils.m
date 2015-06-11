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
#import "RJParseLike.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import <Parse/Parse.h>


@implementation RJParseUtils

#pragma mark - Private Class Methods

+ (void)updateClassQueryWithIncludedKeys:(PFQuery *)query {
    [query includeKey:@"audioQueue"];
    [query includeKey:@"instructionQueue"];
    [query includeKey:@"category"];
    [query includeKey:@"instructor"];
    [query includeKey:@"comments"];
    [query includeKey:@"comments.creator"];
    [query includeKey:@"likes"];
    [query includeKey:@"likes.creator"];
}

#pragma mark - Public Class Methods - Fetching

+ (void)fetchAllCategoriesWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
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
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
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

+ (void)fetchNewClassesWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Class"];
    [self updateClassQueryWithIncludedKeys:query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all instructors\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

+ (void)fetchPopularClassesWithCompletion:(void (^)(NSArray *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Class"];
    [self updateClassQueryWithIncludedKeys:query];
    [query orderByDescending:@"plays"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error fetching all instructors\n\n%@", [error localizedDescription]);
        }
        if (completion) {
            completion(objects);
        }
    }];
}

#pragma mark - Public Class Methods - Updating

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

@end
