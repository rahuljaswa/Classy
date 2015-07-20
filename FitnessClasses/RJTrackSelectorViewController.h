//
//  RJTrackSelectorViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJSingleSelectionViewController.h"


@class RJTrackSelectorViewController;

@protocol RJTrackSelectorViewControllerDelegate <NSObject>

- (void)trackSelectorViewController:(RJTrackSelectorViewController *)trackSelectorViewController didSelectTrack:(RJSoundCloudTrack *)track;

@end


@interface RJTrackSelectorViewController : RJSingleSelectionViewController

@property (nonatomic, weak) id<RJTrackSelectorViewControllerDelegate> trackSelectorDelegate;

@end
