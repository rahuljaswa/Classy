//
//  main.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/4/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#ifdef DEBUG
    #import "RJTouchposeApplication.h"
#endif

int main(int argc, char * argv[]) {
    @autoreleasepool {
#ifdef DEBUG
        return UIApplicationMain(argc, argv,
                                 NSStringFromClass([RJTouchposeApplication class]),
                                 NSStringFromClass([AppDelegate class]));
#else
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
#endif
    }
}
