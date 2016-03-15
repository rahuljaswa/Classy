//
//  RJChoreographedPlayingClassViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJChoreographedPlayingClassViewController;

@protocol RJChoreographedPlayingClassViewControllerDelegate <NSObject>

- (void)choreographedPlayingClassViewControllerPlaybackTimeDidChange:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController;
- (void)choreographedPlayingClassViewControllerReadyToPlayPendingClass:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController;
- (void)choreographedPlayingClassViewControllerTrackDidChange:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController;
- (void)choreographedPlayingClassViewControllerWillPlay:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController;
- (void)choreographedPlayingClassViewControllerWillPause:(RJChoreographedPlayingClassViewController *)choreographedPlayingClassViewController;

@end


@class RJParseClass;
@class RJParseTrack;

@interface RJChoreographedPlayingClassViewController : UIViewController

@property (nonatomic, assign, getter=hasClassStarted, readonly) BOOL classStarted;
@property (nonatomic, assign, getter=isClassPlaying, readonly) BOOL classPlaying;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) RJParseTrack *currentTrack;
@property (nonatomic, weak) id<RJChoreographedPlayingClassViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) RJParseClass *klass;
@property (nonatomic, assign, readonly) NSInteger playbackTime;

- (void)playOrPauseCurrentClass;
- (void)setKlass:(RJParseClass *)klass withAutoPlay:(BOOL)autoPlay;

@end
