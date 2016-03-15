//
//  RJParseKey.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 10/15/15.
//  Copyright © 2015 Rahul Jaswa. All rights reserved.
//

#import <Parse/Parse.h>

FOUNDATION_EXPORT NSString *kRJParseKeyAppleInAppPurchaseKey;


@interface RJParseKey : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *secret;

@end
