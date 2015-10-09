//
//  RJParseClass.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"

typedef NS_ENUM(NSInteger, RJParseClassType) {
    kRJParseClassTypeNone = -1,
    kRJParseClassTypeChoreographed,
    kRJParseClassTypeSelfPaced
};


@class RJParseCategory;
@class RJParseUser;

@interface RJParseClass : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) RJParseCategory *category;
@property (nonatomic, strong) NSNumber *classOrder;
@property (nonatomic, strong) NSNumber *classType;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSString *coverArtURL;
@property (nonatomic, strong) NSArray *exerciseInstructions;
@property (nonatomic, strong) RJParseUser *instructor;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *plays;
@property (nonatomic, assign) BOOL requiresSubscription;
@property (nonatomic, strong) NSArray *tracks;

@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) RJParseClassType formattedClassType;

@end
