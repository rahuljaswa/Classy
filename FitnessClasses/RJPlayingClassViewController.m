//
//  RJPlayingClassViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJClassDetailsViewController.h"
#import "RJClassSummaryView.h"
#import "RJMixpanelConstants.h"
#import "RJParseClass.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJPlayingClassViewController.h"
#import "RJSoundCloudAPIClient.h"
#import "RJSoundCloudTrack.h"
#import "RJStackedTitleView.h"
#import "RJCreditsHelper.h"
#import "RJStyleManager.h"
#import "RJTrackImageCacheEntity.h"
#import "RJUserImageCacheEntity.h"
#import "UIBarButtonItem+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import "UIImageView+FastImageCache.h"
#import <Mixpanel/Mixpanel.h>
@import AVFoundation.AVAsset;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVPlayerItem;
@import AVFoundation.AVSpeechSynthesis;
@import AVFoundation.AVTime;


@interface RJPlayingClassViewController () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong, readwrite) RJParseClass *klass;

@property (nonatomic, strong) AVQueuePlayer *player;
@property (nonatomic, strong) id playerObserver;
@property (nonatomic, assign, getter=isSliderSliding) BOOL sliderSliding;
@property (nonatomic, strong) UILabel *sliderLabel;
@property (nonatomic, assign) CGFloat startPoint;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic, assign) NSTimeInterval playbackTime;
@property (nonatomic, strong, readonly) NSMutableArray *remainingAudioQueue;
@property (nonatomic, strong, readonly) NSMutableArray *remainingInstructionsQueue;

@property (nonatomic, strong, readonly) UILabel *currentInstruction;
@property (nonatomic, strong) RJSoundCloudTrack *currentTrack;
@property (nonatomic, strong, readonly) UIImageView *instructorPicture;
@property (nonatomic, strong, readonly) UILabel *instructorName;
@property (nonatomic, strong, readonly) UIButton *playPauseButton;
@property (nonatomic, strong, readonly) UISlider *slider;
@property (nonatomic, strong, readonly) UIButton *tipButton;
@property (nonatomic, strong, readonly) UILabel *trackArtist;
@property (nonatomic, strong, readonly) UIImageView *trackArtwork;
@property (nonatomic, strong, readonly) UIButton *trackAttributionLogo;
@property (nonatomic, strong, readonly) UILabel *trackTitle;

@property (nonatomic, strong, readonly) RJClassSummaryView *summaryView;
@property (nonatomic, strong, readonly) RJStackedTitleView *titleView;

@end


@implementation RJPlayingClassViewController

#pragma mark - Public Properties

- (void)setKlass:(RJParseClass *)klass {
    [self setKlass:klass withStartPoint:0.0f autoPlay:NO];
}

- (void)setKlass:(RJParseClass *)klass withAutoPlay:(BOOL)autoPlay {
    [self setKlass:klass withStartPoint:0.0f autoPlay:autoPlay];
}

- (void)setKlass:(RJParseClass *)klass withStartPoint:(CGFloat)startPoint autoPlay:(BOOL)autoPlay {
    _klass = klass;
    _startPoint = startPoint;
    [self clearCurrentClass];
    [self prepareClass];
    [self fetchTrackInfoAtAudioQueueIndex:0];
    [self updateClassViewFields];
    if (autoPlay) {
        [self startClass:klass];
    }
}

- (void)updateKlass:(RJParseClass *)klass {
    if ([_klass.objectId isEqualToString:klass.objectId]) {
        _klass = klass;
        [self updateClassViewFields];
    }
}

- (void)setMinimized:(BOOL)minimized {
    _minimized = minimized;
    [[self navigationController] setNavigationBarHidden:_minimized animated:(self.isViewLoaded && self.view.window)];
}

#pragma mark - Private Properties

- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}

#pragma mark - Private Instance Methods

- (void)clearCurrentClass {
    _classStarted = NO;
    self.currentTrack = nil;
    
    if (self.playerObserver) {
        [self.player removeTimeObserver:self.playerObserver];
    }
    [self.player removeObserver:self forKeyPath:@"status"];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareClass {
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = [self.klass.length floatValue];
    
    self.playbackTime = self.startPoint;
    
    _remainingAudioQueue = [[NSMutableArray alloc] init];
    NSUInteger numberOfAudioQueueTracks = [self.klass.audioQueue count];
    for (NSUInteger i = 0; i < numberOfAudioQueueTracks; i++) {
        NSArray *track = self.klass.audioQueue[i];
        CGFloat trackStartPoint = [[track firstObject] floatValue];
        
        CGFloat trackEndPoint;
        if (i == (numberOfAudioQueueTracks - 1)) {
            trackEndPoint = [self.klass.length floatValue];
        } else {
            NSArray *nextTrack = self.klass.audioQueue[i+1];
            trackEndPoint = ([[nextTrack firstObject] floatValue] - 1);
        }
        BOOL trackEndsAfterStartPoint = (trackEndPoint >= self.startPoint);
        BOOL trackStartsAtOrAfterStartPoint = (trackStartPoint >= self.startPoint);
        if (trackStartsAtOrAfterStartPoint || (!trackStartsAtOrAfterStartPoint && trackEndsAfterStartPoint)) {
            [_remainingAudioQueue addObject:track];
        }
    }
    
    _remainingInstructionsQueue = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [self.klass.instructionQueue count]; i++) {
        NSArray *instruction = self.klass.instructionQueue[i];
        CGFloat instructionStartPoint = [[instruction firstObject] floatValue];
        if (instructionStartPoint >= self.startPoint) {
            [_remainingInstructionsQueue addObject:instruction];
        }
    }
    
    NSUInteger remainingInstructions = [_remainingInstructionsQueue count];
    NSUInteger totalInstructions = [self.klass.instructionQueue count];
    if (remainingInstructions < totalInstructions) {
        NSUInteger absoluteIndexOfFirstRemainingInstruction = (totalInstructions - remainingInstructions);
        NSArray *lastInstruction = [self.klass.instructionQueue[(absoluteIndexOfFirstRemainingInstruction - 1)] lastObject];
        self.currentInstruction.text = [NSString stringWithFormat:@"\"%@\"", lastInstruction];
    } else {
        self.currentInstruction.text = NSLocalizedString(@"\"Let's get started!\"", nil);
    }
}

- (void)startClass:(RJParseClass *)klass {
    _classStarted = YES;
    
    NSArray *audioPlaylist = self.remainingAudioQueue;
    NSMutableArray *audioQueue = [[NSMutableArray alloc] init];
    NSUInteger numberOfTracks = [audioPlaylist count];
    for (NSUInteger i = 0; i < numberOfTracks; i++) {
        NSArray *track = audioPlaylist[i];
        NSString *trackID = [track lastObject];
        NSURL *trackURL = [[RJSoundCloudAPIClient sharedAPIClient] authenticatingStreamURLWithTrackID:trackID];
        AVPlayerItem *trackPlayerItem = [AVPlayerItem playerItemWithURL:trackURL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:trackPlayerItem];
        [audioQueue addObject:trackPlayerItem];
    }
    self.player = [AVQueuePlayer queuePlayerWithItems:audioQueue];
    self.player.volume = 0.5f;
    [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [RJParseUtils incrementPlaysForClass:klass completion:nil];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:kRJMixpanelConstantsPlayedClass properties:
     @{
       kRJMixpanelConstantsPlayedClassClassNameDictionaryKey : klass.name,
       kRJMixpanelConstantsPlayedClassClassObjectIDDictionaryKey : klass.objectId
       }];
    [mixpanel.people increment:kRJMixpanelPeopleConstantsPlays by:@1];
}

- (void)startQueues {
    self.playbackTime = self.startPoint;
    [self.player play];
    [self updateClassViewFields];
    
    __weak typeof(self) weakSelf = self;
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.playbackTime += 0.1;
        if (!strongSelf.isSliderSliding) {
            [strongSelf.slider setValue:strongSelf.playbackTime animated:YES];
        }
        
        NSUInteger totalTime = [strongSelf.klass.length unsignedIntegerValue];
        strongSelf.titleView.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString hhmmaaForTotalSeconds:strongSelf.playbackTime], [NSString hhmmaaForTotalSeconds:totalTime]];
        
        NSArray *nextInstruction = [strongSelf.remainingInstructionsQueue firstObject];
        if (nextInstruction && (strongSelf.playbackTime >= [[nextInstruction firstObject] doubleValue])) {
            NSArray *instruction = [strongSelf.remainingInstructionsQueue firstObject];
            NSString *instructionString = [instruction lastObject];
            
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:instructionString];
            utterance.rate = 0.05f;
            [strongSelf.synthesizer speakUtterance:utterance];
            if ([strongSelf.remainingInstructionsQueue count] > 0) {
                [strongSelf.remainingInstructionsQueue removeObjectAtIndex:0];
            }
            
            strongSelf.currentInstruction.text = [NSString stringWithFormat:@"\"%@\"", instructionString];
        }
    }];
}

- (void)updateClassViewFields {
    self.summaryView.classTitle.text = [self.klass.name uppercaseString];
    self.titleView.textLabel.text = [self.klass.name uppercaseString];
    
    self.summaryView.track.text = self.currentTrack.title;
    self.trackTitle.text = self.currentTrack.title;
    
    self.trackArtist.text = self.currentTrack.artist;
    self.instructorName.text = [self.klass.instructor.name uppercaseString];
    
    if (self.klass.instructor.profilePicture) {
        NSURL *url = [NSURL URLWithString:self.klass.instructor.profilePicture.url];
        RJUserImageCacheEntity *entity = [[RJUserImageCacheEntity alloc] initWithUserImageURL:url objectID:self.klass.instructor.objectId];
        [self.instructorPicture setImageEntity:entity formatName:kRJUserImageFormatCard16BitBGR80x80 placeholder:nil];
    } else {
        self.instructorPicture.image = nil;
    }
    
    if (self.currentTrack) {
        [self.trackAttributionLogo setImage:[UIImage imageNamed:@"soundCloudIcon"] forState:UIControlStateNormal];
        NSURL *url = [NSURL URLWithString:self.currentTrack.artworkURL];
        RJTrackImageCacheEntity *trackEntity = [[RJTrackImageCacheEntity alloc] initWithTrackImageURL:url objectID:self.currentTrack.trackID];
        [self.trackArtwork setImageEntity:trackEntity formatName:kRJTrackImageFormatCardSquare16BitBGR placeholder:nil];
        [self.summaryView.trackArtwork setImageEntity:trackEntity formatName:kRJTrackImageFormatCardSquare16BitBGR placeholder:nil];
    } else {
        [self.trackAttributionLogo setImage:nil forState:UIControlStateNormal];
        self.trackArtwork.image = nil;
        self.summaryView.trackArtwork.image = nil;
    }
    
    NSString *imageName = (self.player.rate == 0.0f) ? @"playIcon" : @"pauseIcon";
    [self.playPauseButton setImage:[UIImage tintableImageNamed:imageName] forState:UIControlStateNormal];
    [self.summaryView.playPauseButton setImage:[UIImage tintableImageNamed:imageName] forState:UIControlStateNormal];
}

- (void)fetchTrackInfoAtAudioQueueIndex:(NSUInteger)index {
    if ([self.remainingAudioQueue count] > 0) {
        NSString *currentTrackID = [self.remainingAudioQueue[index] lastObject];
        RJSoundCloudAPIClient *apiClient = [RJSoundCloudAPIClient sharedAPIClient];
        [apiClient getTrackWithTrackID:currentTrackID
                               success:^(RJSoundCloudTrack *track) {
                                   self.currentTrack = track;
                                   [self updateClassViewFields];
                               }
                               failure:^(NSError *error) {
                                   
                               }];
    }
}

- (void)playerItemDidFinish:(NSNotification *)notification {
    AVPlayerItem *playerItem = notification.object;
    if ([playerItem.asset isKindOfClass:[AVURLAsset class]]) {
        AVURLAsset *finishedURLAsset = (AVURLAsset *)playerItem.asset;
        NSString *finishedURLString = [finishedURLAsset.URL absoluteString];
        
        NSUInteger indexOfTrackInRemainingAudioQueue = [self.remainingAudioQueue indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString *trackID = [obj lastObject];
            NSURL *trackURL = [[RJSoundCloudAPIClient sharedAPIClient] authenticatingStreamURLWithTrackID:trackID];
            NSString *trackURLString = [trackURL absoluteString];
            return [finishedURLString isEqualToString:trackURLString];
        }];
        
        if (indexOfTrackInRemainingAudioQueue != NSNotFound) {
            [self.remainingAudioQueue removeObjectAtIndex:indexOfTrackInRemainingAudioQueue];
            if ([self.remainingAudioQueue count] > 0) {
                [self fetchTrackInfoAtAudioQueueIndex:0];
            } else {
                self.currentInstruction.text = NSLocalizedString(@"\"All done! Congrats and see you again soon.\"", nil);
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.currentInstruction.text];
                utterance.rate = 0.05f;
                [self.synthesizer speakUtterance:utterance];
            }
        }
    }
}

#pragma mark - Private Instance Methods - Handlers

- (void)playPauseButtonPressed:(UIButton *)button {
    if (self.klass) {
        if (self.player.rate == 0.0f) {
            if (self.hasClassStarted) {
                [self.player play];
            } else {
                [self startClass:self.klass];
            }
        } else {
            [self.player pause];
        }
        [self updateClassViewFields];
    }
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer {
    if (self.isMinimized) {
        self.minimized = !self.minimized;
        [self.delegate playingClassViewController:self delegateWillMinimize:self.minimized];
    }
}

- (void)infoButtonPressed:(UIButton *)button {
    RJClassDetailsViewController *detailsViewController = [[RJClassDetailsViewController alloc] initWithNibName:nil bundle:nil];
    detailsViewController.klass = self.klass;
    [[self navigationController] pushViewController:detailsViewController animated:YES];
}

- (void)minimizeButtonPressed:(UIButton *)button {
    if (!self.isMinimized) {
        self.minimized = !self.minimized;
        [self.delegate playingClassViewController:self delegateWillMinimize:self.minimized];
    }
}

- (void)tipButtonPressed:(UIButton *)button {
    [[RJCreditsHelper sharedInstance] tipInstructorForClass:self.klass completion:nil];
}

- (void)sliderEndedSliding:(UISlider *)slider {
    self.sliderSliding = NO;
    
    [self setKlass:self.klass withStartPoint:slider.value autoPlay:(self.player.rate > 0.0f)];
    [self.sliderLabel removeFromSuperview];
}

- (void)sliderStartedSliding:(UISlider *)slider {
    self.sliderSliding = YES;
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    self.sliderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.sliderLabel.backgroundColor = [UIColor whiteColor];
    self.sliderLabel.textColor = styleManager.darkTextColor;
    self.sliderLabel.font = styleManager.smallBoldFont;
    self.sliderLabel.layer.cornerRadius = 2.0f;
    self.sliderLabel.clipsToBounds = YES;
    [self.view addSubview:self.sliderLabel];
}

- (void)sliderValueChanged:(UISlider *)slider {
    CGRect trackRect = [slider trackRectForBounds:slider.bounds];
    CGRect thumbRect = [slider thumbRectForBounds:slider.bounds trackRect:trackRect value:slider.value];
    CGRect convertedThumbRect = [slider convertRect:thumbRect toView:self.view];
    
    self.sliderLabel.text = [NSString stringWithFormat:@" %@ ", [NSString hhmmaaForTotalSeconds:slider.value]];
    CGSize sliderLabelSize = [self.sliderLabel intrinsicContentSize];
    self.sliderLabel.frame = CGRectMake(0.0f, 0.0f, sliderLabelSize.width, sliderLabelSize.height);
    self.sliderLabel.center = CGPointMake(CGRectGetMidX(convertedThumbRect), CGRectGetMinY(slider.frame) - 10.0f);
}

- (void)trackAttributionButtonPressed:(UIButton *)button {
    if (self.currentTrack) {
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *url = [NSURL URLWithString:self.currentTrack.permalinkURL];
        if ([application canOpenURL:url]) {
            [application openURL:url];
        }
    }
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [self clearCurrentClass];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentInstruction = [[UILabel alloc] initWithFrame:CGRectZero];
        _instructorName = [[UILabel alloc] initWithFrame:CGRectZero];
        _instructorPicture = [[UIImageView alloc] initWithFrame:CGRectZero];
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _slider = [[UISlider alloc] init];
        _summaryView = [[RJClassSummaryView alloc] initWithFrame:CGRectZero];
        _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleView = [[RJStackedTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        _trackTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _trackAttributionLogo = [UIButton buttonWithType:UIButtonTypeCustom];
        _trackArtwork = [[UIImageView alloc] initWithFrame:CGRectZero];
        _trackArtist = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *currentInstruction = self.currentInstruction;
    currentInstruction.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:currentInstruction];
    UIView *instructorName = self.instructorName;
    instructorName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:instructorName];
    UIView *instructorPicture = self.instructorPicture;
    instructorPicture.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:instructorPicture];
    UIView *playPauseButton = self.playPauseButton;
    playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:playPauseButton];
    UIView *slider = self.slider;
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:slider];
    UIView *summaryView = self.summaryView;
    summaryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:summaryView];
    UIView *tipButton = self.tipButton;
    tipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tipButton];
    UIView *trackTitle = self.trackTitle;
    trackTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:trackTitle];
    UIView *trackAttributionLogo = self.trackAttributionLogo;
    trackAttributionLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:trackAttributionLogo];
    UIView *trackArtwork = self.trackArtwork;
    trackArtwork.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:trackArtwork];
    UIView *trackArtist = self.trackArtist;
    trackArtist.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:trackArtist];
    
    [self.view sendSubviewToBack:trackArtwork];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(currentInstruction, instructorName, instructorPicture, playPauseButton, slider, summaryView, tipButton, trackArtist, trackArtwork, trackAttributionLogo, trackTitle);
    NSDictionary *metrics = @{
                              @"spacing" : @(3.0f),
                              @"sideMargin" : @(6.0f),
                              };
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[summaryView(44)]-20-[trackArtwork]-6-[slider][currentInstruction]-25-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[trackTitle]-spacing-[trackArtist]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[trackAttributionLogo]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[summaryView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[currentInstruction]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[trackArtwork]-20-[instructorPicture]-10-[instructorName(100)]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[trackAttributionLogo(==27)]->=spacing-[trackTitle]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[trackAttributionLogo]->=spacing-[trackArtist]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:instructorPicture attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:instructorPicture attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeHeight multiplier:0.3f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:trackArtwork attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:instructorName attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:playPauseButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:playPauseButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:instructorName attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:tipButton attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:instructorPicture attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeBottom multiplier:1.0f constant:20.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == self.player) && [keyPath isEqualToString:@"status"] && (self.player.status == AVPlayerStatusReadyToPlay)) {
        NSArray *firstTrack = [self.remainingAudioQueue objectAtIndex:0];
        CGFloat firstTrackDefaultStartPoint = [[firstTrack firstObject] floatValue];
        [self.player.currentItem seekToTime:CMTimeMake(self.startPoint - firstTrackDefaultStartPoint, 1) completionHandler:^(BOOL finished) {
            [self startQueues];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem minimizeBarButtonItemWithTarget:self action:@selector(minimizeButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:styleManager.accentColor];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem toggleBarButtonItemWithTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:styleManager.accentColor];
    
    [self.trackAttributionLogo addTarget:self action:@selector(trackAttributionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.summaryView.playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.tipButton addTarget:self action:@selector(tipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderEndedSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel)];
    [self.slider addTarget:self action:@selector(sliderStartedSliding:) forControlEvents:UIControlEventTouchDown];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.view.backgroundColor = styleManager.themeColor;
    
    self.currentInstruction.textAlignment = NSTextAlignmentCenter;
    self.currentInstruction.lineBreakMode = NSLineBreakByWordWrapping;
    self.currentInstruction.numberOfLines = 0;
    self.currentInstruction.textColor = styleManager.accentColor;
    self.currentInstruction.font = styleManager.mediumFont;
    
    self.instructorName.lineBreakMode = NSLineBreakByWordWrapping;
    self.instructorName.numberOfLines = 2;
    self.instructorName.textColor = styleManager.lightTextColor;
    self.instructorName.font = styleManager.smallBoldFont;
    
    self.instructorPicture.contentMode = UIViewContentModeScaleAspectFit;
    
    self.trackArtist.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.trackArtwork.contentMode = UIViewContentModeScaleAspectFit;
    
    self.trackTitle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.titleView.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.detailTextLabel.textColor = styleManager.windowTintColor;
    self.titleView.detailTextLabel.font = styleManager.smallBoldFont;
    
    self.titleView.textLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.textLabel.textColor = styleManager.lightTextColor;
    self.titleView.textLabel.font = styleManager.navigationBarFont;
    
    [self.playPauseButton setTintColor:styleManager.windowTintColor];
    [self.playPauseButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.0 alpha:0.8]] forState:UIControlStateNormal];
    self.playPauseButton.imageEdgeInsets = UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f);
    
    self.summaryView.playPauseButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.summaryView.playPauseButton.imageEdgeInsets =UIEdgeInsetsMake(3.0f, 3.0f, 7.0f, 0.0f);
    [self.summaryView.playPauseButton setTintColor:[UIColor whiteColor]];
    [self.summaryView.playPauseButton setTintColor:styleManager.accentColor];
    
    self.summaryView.classTitle.font = styleManager.smallBoldFont;
    self.summaryView.classTitle.textColor = styleManager.lightTextColor;
    
    self.summaryView.track.font = styleManager.smallFont;
    self.summaryView.track.textColor = styleManager.lightTextColor;
    
    self.trackArtist.textColor = styleManager.lightTextColor;
    self.trackArtist.font = styleManager.smallFont;
    
    self.trackTitle.textColor = styleManager.lightTextColor;
    self.trackTitle.font = styleManager.smallBoldFont;

    self.tipButton.titleLabel.font = styleManager.smallBoldFont;
    [self.tipButton setTitle:NSLocalizedString(@"Tip Instructor", nil) forState:UIControlStateNormal];
    [self.tipButton setTitleColor:styleManager.windowTintColor forState:UIControlStateNormal];
    [self.tipButton setTitleColor:styleManager.darkTextColor forState:UIControlStateHighlighted];
    [self.tipButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.tipButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    self.tipButton.layer.borderWidth = 2.0f;
    self.tipButton.layer.borderColor = styleManager.windowTintColor.CGColor;
}

@end
