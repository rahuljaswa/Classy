//
//  RJTrackSelectorViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJSinglePFObjectSelectionViewController.h"


@class RJTrackSelectorViewController;

@protocol RJTrackSelectorViewControllerDelegate <NSObject>

- (void)trackSelectorViewController:(RJTrackSelectorViewController *)trackSelectorViewController didSelectTrack:(RJSoundCloudTrack *)track;

@end


@interface RJTrackSelectorViewController : RJSinglePFObjectSelectionViewController

@property (nonatomic, weak) id<RJTrackSelectorViewControllerDelegate> trackSelectorDelegate;

@end
