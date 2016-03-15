//
//  RJParseSubscription.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 10/18/15.
//  Copyright © 2015 Rahul Jaswa. All rights reserved.
//

#import "RJParseComparablePFObject.h"


@interface RJParseSubscription : RJParseComparablePFObject <PFSubclassing>

@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSDate *expirationDate;

@end
