//
//  RJPlayingClassViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJPlayingClassViewController;

@protocol RJPlayingClassViewControllerDelegate <NSObject>

- (void)playingClassViewController:(RJPlayingClassViewController *)playingClassViewController delegateWillMinimize:(BOOL)minimize;

@end



@class RJParseClass;

@interface RJPlayingClassViewController : UIViewController

@property (nonatomic, weak) id<RJPlayingClassViewControllerDelegate> delegate;

@property (nonatomic, assign, getter=hasClassStarted, readonly) BOOL classStarted;
@property (nonatomic, strong, readonly) RJParseClass *klass;
@property (nonatomic, assign, getter=isMinimized) BOOL minimized;

- (void)setKlass:(RJParseClass *)klass withAutoPlay:(BOOL)autoPlay;

@end
