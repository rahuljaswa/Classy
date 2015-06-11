//
//  RJParseUtils.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RJParseCategory;
@class RJParseClass;
@class RJParseUser;

@interface RJParseUtils : NSObject

+ (void)fetchAllCategoriesWithCompletion:(void (^)(NSArray *categories))completion;
+ (void)fetchAllInstructorsWithCompletion:(void (^)(NSArray *instructors))completion;
+ (void)fetchClassesForCategory:(RJParseCategory *)category completion:(void (^)(NSArray *classes))completion;
+ (void)fetchClassesForInstructor:(RJParseUser *)instructor completion:(void (^)(NSArray *classes))completion;
+ (void)fetchClassWithId:(NSString *)objectId completion:(void (^)(RJParseClass *klass))completion;
+ (void)fetchNewClassesWithCompletion:(void (^)(NSArray *))completion;
+ (void)fetchPopularClassesWithCompletion:(void (^)(NSArray *popularClasses))completion;

+ (void)incrementPlaysForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;
+ (void)incrementTipsForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;

+ (void)insertCommentForClass:(RJParseClass *)klass text:(NSString *)text completion:(void (^)(BOOL success))completion;
+ (void)insertLikeForClass:(RJParseClass *)klass completion:(void (^)(BOOL success))completion;

@end
