//
//  RJPlayingClassNavigationController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJPlayingClassNavigationController.h"
#import "RJPlayingClassViewController.h"
#import "RJStyleManager.h"


@interface RJPlayingClassNavigationController ()

@end


@implementation RJPlayingClassNavigationController

#pragma mark - Public Instance Methods

- (instancetype)init {
    _playingClassViewController = [[RJPlayingClassViewController alloc] initWithNibName:nil bundle:nil];
    self = [super initWithRootViewController:_playingClassViewController];
    if (self) {
        _playingClassViewController.minimized = YES;
        _playingClassViewController.edgesForExtendedLayout = UIRectEdgeAll;
        _playingClassViewController.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.edgesForExtendedLayout = UIRectEdgeTop;
}

@end
