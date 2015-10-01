//
//  RJChoreographedPlayingClassViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJExerciseInstructionCell.h"
#import "RJExerciseStepsViewController.h"
#import "RJChoreographedPlayingClassViewController.h"
#import "RJInsetLabel.h"
#import "RJMixpanelConstants.h"
#import "RJParseClass.h"
#import "RJParseExercise.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseTrack.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJSoundCloudAPIClient.h"
#import "RJStyleManager.h"
#import "RJTrackImageCacheEntity.h"
#import "RJUserImageCacheEntity.h"
#import "UIImage+RJAdditions.h"
#import "UIImageView+FastImageCache.h"
#import <Mixpanel/Mixpanel.h>
@import AVFoundation.AVAsset;
@import AVFoundation.AVAudioPlayer;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVPlayerItem;
@import AVFoundation.AVSpeechSynthesis;
@import AVFoundation.AVTime;

static NSString *const kChoreographedPlayingClassViewControllerCellID = @"ChoreographedPlayingClassViewControllerCellID";
static const CGFloat kPlayerNonUtteranceVolume = 1.0f;
static const CGFloat kPlayerUtteranceVolume = 0.3f;


@interface RJChoreographedPlayingClassViewController () <AVSpeechSynthesizerDelegate, RJExerciseInstructionCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readwrite) RJParseClass *klass;

@property (nonatomic, strong) AVAudioPlayer *beepPlayer;
@property (nonatomic, strong) AVQueuePlayer *player;
@property (nonatomic, strong) id playerObserver;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic, assign, readwrite) NSInteger playbackTime;

@property (nonatomic, strong, readwrite) RJParseTrack *currentTrack;

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, strong, readonly) UIImageView *instructorPicture;
@property (nonatomic, strong, readonly) UILabel *instructorName;
@property (nonatomic, strong, readonly) UIButton *playPauseButton;
@property (nonatomic, strong, readonly) UIView *spacer;
@property (nonatomic, strong, readonly) UIButton *tipButton;
@property (nonatomic, strong, readonly) UILabel *trackArtist;
@property (nonatomic, strong, readonly) UIImageView *trackArtwork;
@property (nonatomic, strong, readonly) UIButton *trackAttributionLogo;
@property (nonatomic, strong, readonly) UILabel *trackTitle;

@property (nonatomic, strong, readonly) NSArray *sortedExerciseInstructions;

@property (nonatomic, assign, getter=shouldIgnorePlayerChanges) BOOL ignorePlayerChanges;

@end


@implementation RJChoreographedPlayingClassViewController

#pragma mark - Public Properties

- (BOOL)isClassPlaying {
    return self.player.rate != 0.0f;
}

- (void)setCurrentTrack:(RJParseTrack *)currentTrack {
    _currentTrack = currentTrack;
    if ([self.delegate respondsToSelector:@selector(choreographedPlayingClassViewControllerTrackDidChange:)]) {
        [self.delegate choreographedPlayingClassViewControllerTrackDidChange:self];
    }
}

- (void)setKlass:(RJParseClass *)klass {
    [self setKlass:klass withStartPoint:0.0f autoPlay:NO];
}

- (void)setKlass:(RJParseClass *)klass withAutoPlay:(BOOL)autoPlay {
    [self setKlass:klass withStartPoint:0.0f autoPlay:autoPlay];
}

- (void)setKlass:(RJParseClass *)klass withStartPoint:(NSInteger)startPoint autoPlay:(BOOL)autoPlay {
    [self clearCurrentClass];
    _klass = klass;
    _sortedExerciseInstructions = [klass.exerciseInstructions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startPoint" ascending:YES]]];
    _playbackTime = startPoint;
    [self fetchCurrentTrackInfo];
    
    [self updateClassViewFields];
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(choreographedPlayingClassViewControllerPlaybackTimeDidChange:)]) {
        [self.delegate choreographedPlayingClassViewControllerPlaybackTimeDidChange:self];
    }
    
    if (autoPlay) {
        [self playCurrentClass];
    } else {
        if ([self.delegate respondsToSelector:@selector(choreographedPlayingClassViewControllerReadyToPlayPendingClass:)]) {
            [self.delegate choreographedPlayingClassViewControllerReadyToPlayPendingClass:self];
        }
    }
}

#pragma mark - Private Properties

- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}

#pragma mark - Private Protocols - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.player.volume = kPlayerUtteranceVolume;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.player.volume = kPlayerNonUtteranceVolume;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.player.volume = kPlayerNonUtteranceVolume;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.player.volume = kPlayerUtteranceVolume;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.player.volume = kPlayerNonUtteranceVolume;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    if (NSLocationInRange(0, characterRange)) {
        self.player.volume = kPlayerUtteranceVolume;
    }
}

#pragma mark - Private Protocols - RJExerciseInstructionCellDelegate

- (void)exerciseInstructionCellDidSelectLeftSideAccessoryButton:(RJExerciseInstructionCell *)exerciseInstructionCell {
    if (!self.shouldIgnorePlayerChanges) {
        [self setKlass:self.klass withStartPoint:[exerciseInstructionCell.exerciseInstruction.startPoint integerValue] autoPlay:YES];
        [self.collectionView reloadData];
        self.ignorePlayerChanges = YES;
    }
}

#pragma mark - Private Protocols - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static RJExerciseInstructionCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[RJExerciseInstructionCell alloc] initWithFrame:CGRectZero];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    CGFloat height = [sizingCell sizeThatFits:CGSizeMake(CGRectGetWidth(collectionView.bounds), CGFLOAT_MAX)].height;
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), height);
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJParseExerciseInstruction *instruction = self.sortedExerciseInstructions[indexPath.item];
    RJParseExercise *exercise = instruction.exercise;
    if (exercise.steps && ([exercise.steps count] > 0)) {
        RJExerciseStepsViewController *stepsViewController = [[RJExerciseStepsViewController alloc] init];
        stepsViewController.exercise = exercise;
        [[self navigationController] pushViewController:stepsViewController animated:YES];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sortedExerciseInstructions count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJExerciseInstructionCell *cell = (RJExerciseInstructionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kChoreographedPlayingClassViewControllerCellID forIndexPath:indexPath];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Private Instance Methods

- (void)clearCurrentClass {
    _classStarted = NO;
    _currentTrack = nil;
    _playbackTime = 0.0;
    
    if (self.playerObserver) {
        [self.player removeTimeObserver:self.playerObserver];
    }
    [self.player removeObserver:self forKeyPath:@"status"];
    self.player = nil;
    
    [self.beepPlayer removeObserver:self forKeyPath:@"status"];
    self.beepPlayer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureCell:(RJExerciseInstructionCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    RJParseExerciseInstruction *instruction = self.sortedExerciseInstructions[indexPath.item];
    cell.exerciseInstruction = instruction;
    cell.backgroundColor = styleManager.themeBackgroundColor;
    
    cell.leftSideAccessoryButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.leftSideAccessoryButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateNormal];
    [cell.leftSideAccessoryButton setBackgroundImage:[UIImage imageWithColor:styleManager.tintLightGrayColor] forState:UIControlStateHighlighted];
    [cell.leftSideAccessoryButton setImage:[UIImage tintableImageNamed:@"playIcon"] forState:UIControlStateNormal];
    cell.leftSideAccessoryButton.imageView.tintColor = styleManager.themeTextColor;
    
    NSInteger startPoint = [instruction.startPoint integerValue];
    
    cell.leftSideAccessoryButton.titleLabel.font = styleManager.tinyFont;
    [cell.leftSideAccessoryButton setTitle:[NSString hhmmaaForTotalSeconds:startPoint] forState:UIControlStateNormal];
    [cell.leftSideAccessoryButton setTitleColor:styleManager.themeTextColor forState:UIControlStateNormal];
    
    cell.leftSideAccessoryButton.imageEdgeInsets = UIEdgeInsetsMake(18.0f, 18.0f, 28.0f, 18.0f);
    cell.leftSideAccessoryButton.titleEdgeInsets = UIEdgeInsetsMake(30.0, -28.0f, 0.0f, 0.0f);
    
    cell.titleLabel.text = nil;
    NSString *titleLabelString = [instruction.exercise.title uppercaseString];
    
    if (self.playbackTime >= startPoint)  {
        if (indexPath.item == ([self.sortedExerciseInstructions count] - 1)) {
            cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleLabelString attributes:
                                              @{
                                                NSForegroundColorAttributeName : styleManager.accentColor,
                                                NSFontAttributeName : styleManager.mediumBoldFont
                                                }];
        } else {
            RJParseExerciseInstruction *nextInstruction = self.sortedExerciseInstructions[indexPath.item + 1];
            NSInteger nextInstructionStartPoint = [nextInstruction.startPoint integerValue];
            if (self.playbackTime < nextInstructionStartPoint) {
                cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleLabelString attributes:
                                                  @{
                                                    NSForegroundColorAttributeName : styleManager.accentColor,
                                                    NSFontAttributeName : styleManager.mediumBoldFont
                                                    }];
            } else {
                cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleLabelString attributes:
                                                  @{
                                                    NSForegroundColorAttributeName : styleManager.themeTextColor,
                                                    NSFontAttributeName : styleManager.mediumFont,
                                                    NSStrikethroughStyleAttributeName : @(NSUnderlineStyleThick)
                                                    }];
            }
        }
    } else {
        cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleLabelString attributes:
                                          @{
                                            NSForegroundColorAttributeName : styleManager.themeTextColor,
                                            NSFontAttributeName : styleManager.mediumFont
                                            }];
    }
}

- (void)playNecessaryAudioForNextEventStartPoint:(NSInteger)nextEventStartPoint {
    NSInteger instructionCutOffTime = 10;
    NSInteger beepCutOffTime = 5;
    NSInteger timeToNextEvent = (nextEventStartPoint - self.playbackTime);
    if (timeToNextEvent == instructionCutOffTime) {
        NSString *utteranceString = [NSString stringWithFormat:@"%li more seconds", (long)instructionCutOffTime];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:utteranceString];
        [self.synthesizer speakUtterance:utterance];
    } else if ((timeToNextEvent <= beepCutOffTime) && (timeToNextEvent >= 0)) {
        [self.beepPlayer play];
    }
}

- (void)speakUtteranceIfNecessary {
    NSUInteger numberOfExerciseInstructions = [self.sortedExerciseInstructions count];
    for (NSUInteger i = 0; i < numberOfExerciseInstructions; i++) {
        RJParseExerciseInstruction *instruction = self.sortedExerciseInstructions[i];
        NSInteger instructionStartPointIntegerValue = [instruction.startPoint integerValue];
        if (instructionStartPointIntegerValue == self.playbackTime) {
            NSString *utteranceString = [NSString stringWithFormat:@"%@ for %@", instruction.exercise.title, instruction.allLevelsQuantity];
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:utteranceString];
            [self.synthesizer speakUtterance:utterance];
            break;
        } else if (i < (numberOfExerciseInstructions - 1)) {
            RJParseExerciseInstruction *nextInstruction = self.sortedExerciseInstructions[i+1];
            NSInteger nextInstructionStartPointIntegerValue = [nextInstruction.startPoint integerValue];
            if (self.playbackTime != nextInstructionStartPointIntegerValue) {
                [self playNecessaryAudioForNextEventStartPoint:nextInstructionStartPointIntegerValue];
            }
        }
    }
}

- (void)startClass:(RJParseClass *)klass {
    _classStarted = YES;
    
    NSArray *tracks = [self tracksForCurrentPlaybackTime];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (RJParseTrack *track in tracks) {
        NSURL *trackURL = [[RJSoundCloudAPIClient sharedAPIClient] authenticatingStreamURLWithStreamURL:track.streamURL];
        AVPlayerItem *trackPlayerItem = [AVPlayerItem playerItemWithURL:trackURL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:trackPlayerItem];
        [items addObject:trackPlayerItem];
    }
    
    NSError *error;
    NSURL *beepURL = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"sound_beep" ofType:@"wav"]];
    self.beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    [self.beepPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    self.player = [AVQueuePlayer queuePlayerWithItems:items];
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
    [self speakUtteranceIfNecessary];
    [self.player play];
    
    [self updateClassViewFields];
    
    __weak typeof(self) weakSelf = self;
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.playbackTime += 1.0;

        strongSelf.ignorePlayerChanges = NO;
        
        if ([strongSelf.delegate respondsToSelector:@selector(choreographedPlayingClassViewControllerPlaybackTimeDidChange:)]) {
            [strongSelf.delegate choreographedPlayingClassViewControllerPlaybackTimeDidChange:strongSelf];
        }
        
        [strongSelf.collectionView reloadData];
        [strongSelf speakUtteranceIfNecessary];
    }];
}

- (NSArray *)tracksForCurrentPlaybackTime {
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    NSUInteger trackStartPoint = 0;
    for (RJParseTrack *track in self.klass.tracks) {
        NSInteger trackEndPoint = (trackStartPoint + [track.length integerValue]);
        if (trackEndPoint >= self.playbackTime) {
            [tracks addObject:track];
        }
        trackStartPoint = trackEndPoint;
    }
    return tracks;
}

- (void)updateClassViewFields {
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
        [self.trackAttributionLogo setImage:[UIImage tintableImageNamed:@"soundCloudIcon"] forState:UIControlStateNormal];
        NSURL *url = [NSURL URLWithString:self.currentTrack.artworkURL];
        RJTrackImageCacheEntity *trackEntity = [[RJTrackImageCacheEntity alloc] initWithTrackImageURL:url objectID:self.currentTrack.objectId];
        [self.trackArtwork setImageEntity:trackEntity formatName:kRJTrackImageFormatCardSquare16BitBGR placeholder:nil];
    } else {
        [self.trackAttributionLogo setImage:nil forState:UIControlStateNormal];
        self.trackArtwork.image = nil;
    }
    
    NSString *imageName = (self.player.rate == 0.0f) ? @"circledPlayIcon" : @"pauseIcon";
    [self.playPauseButton setImage:[UIImage tintableImageNamed:imageName] forState:UIControlStateNormal];
}

- (NSInteger)currentTrackIndex {
    NSInteger trackStartPoint = 0;
    NSInteger tracksCount = [self.klass.tracks count];
    for (NSUInteger i = 0; i < tracksCount; i++) {
        RJParseTrack *track = self.klass.tracks[i];
        NSInteger trackEndPoint = (trackStartPoint + [track.length integerValue]);
        if ((trackStartPoint <= self.playbackTime) && (trackEndPoint >= self.playbackTime)) {
            return i;
        }
        trackStartPoint = trackEndPoint;
    }
    return NSNotFound;
}

- (void)fetchCurrentTrackInfo {
    NSInteger currentTrackIndex = [self currentTrackIndex];
    if (currentTrackIndex != NSNotFound) {
        self.currentTrack = self.klass.tracks[currentTrackIndex];
        [self updateClassViewFields];
    }
}

- (void)playerItemDidFinish:(NSNotification *)notification {
    [self fetchCurrentTrackInfo];
}

#pragma mark - Private Instance Methods - Handlers

- (void)playPauseButtonPressed:(UIButton *)button {
    [self playOrPauseCurrentClass];
}

- (void)tipButtonPressed:(UIButton *)button {
    [[RJCreditsHelper sharedInstance] tipInstructorForClass:self.klass completion:nil];
}

- (void)trackAttributionButtonPressed:(UIButton *)button {
    if (self.currentTrack) {
        UIApplication *application = [UIApplication sharedApplication];
        if (self.currentTrack.permalinkURL) {
            NSURL *url = [NSURL URLWithString:self.currentTrack.permalinkURL];
            if ([application canOpenURL:url]) {
                [application openURL:url];
            }
        }
    }
}

#pragma mark - Public Instance Methods - Init

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    return [self init];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _instructorName = [[UILabel alloc] initWithFrame:CGRectZero];
        _instructorPicture = [[UIImageView alloc] initWithFrame:CGRectZero];
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _spacer = [[UIView alloc] initWithFrame:CGRectZero];
        _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _trackTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _trackAttributionLogo = [UIButton buttonWithType:UIButtonTypeCustom];
        _trackArtwork = [[UIImageView alloc] initWithFrame:CGRectZero];
        _trackArtist = [[UILabel alloc] initWithFrame:CGRectZero];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return self;
}

#pragma mark - Public Instance Methods - Layout

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *collectionView = self.collectionView;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:collectionView];
    UIView *instructorName = self.instructorName;
    instructorName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:instructorName];
    UIView *instructorPicture = self.instructorPicture;
    instructorPicture.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:instructorPicture];
    UIView *playPauseButton = self.playPauseButton;
    playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:playPauseButton];
    UIView *spacer = self.spacer;
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:spacer];
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
    
    NSDictionary *views = NSDictionaryOfVariableBindings(collectionView, instructorName, instructorPicture, playPauseButton, spacer, tipButton, trackArtist, trackArtwork, trackAttributionLogo, trackTitle);
    NSDictionary *metrics = @{
                              @"spacing" : @(3.0f),
                              @"sideMargin" : @(6.0f),
                              };
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[trackArtwork(120)]-10-[trackTitle(15)][trackArtist(15)]-20-[spacer(1)][collectionView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[trackArtwork]-15-[trackAttributionLogo]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spacer]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[trackArtwork]-20-[instructorPicture(30)]-10-[instructorName]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[trackAttributionLogo(25)]-10-[trackArtist]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[trackTitle]-sideMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:instructorPicture attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:trackArtwork attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:trackArtist attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:trackTitle attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:instructorName attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:playPauseButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:playPauseButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:playPauseButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:55.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:playPauseButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:55.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:instructorName attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:instructorPicture attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:trackArtwork attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:instructorPicture attribute:NSLayoutAttributeBottom multiplier:1.0f constant:20.0f]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:tipButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f]];
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    [self clearCurrentClass];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == self.player) && [keyPath isEqualToString:@"status"] && (self.player.status == AVPlayerStatusReadyToPlay)) {
        RJParseTrack *firstTrackToPlay = [[self tracksForCurrentPlaybackTime] firstObject];
        NSInteger timeToSeekInCurrentItem = 0;
        NSInteger trackStartPoint = 0;
        for (RJParseTrack *track in self.klass.tracks) {
            if ([track.objectId isEqualToString:firstTrackToPlay.objectId]) {
                timeToSeekInCurrentItem = (self.playbackTime - trackStartPoint);
                break;
            }
            trackStartPoint += [track.length integerValue];
        }

        [self.player.currentItem seekToTime:CMTimeMake(timeToSeekInCurrentItem, 1) completionHandler:^(BOOL finished) {
            [self startQueues];
        }];
    }
}

- (void)pauseCurrentClass {
    [self.player pause];
    if ([self.delegate respondsToSelector:@selector(choreographedPlayingClassViewControllerWillPause:)]) {
        [self.delegate choreographedPlayingClassViewControllerWillPause:self];
    }
}

- (void)playCurrentClass {
    if (self.hasClassStarted) {
        [self.player play];
    } else {
        [self startClass:self.klass];
    }
    if ([self.delegate respondsToSelector:@selector(choreographedPlayingClassViewControllerWillPlay:)]) {
        [self.delegate choreographedPlayingClassViewControllerWillPlay:self];
    }
}

- (void)playOrPauseCurrentClass {
    if (self.klass) {
        if (self.player.rate == 0.0f) {
            [self playCurrentClass];
        } else {
            [self pauseCurrentClass];
        }
        [self updateClassViewFields];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    [self.collectionView registerClass:[RJExerciseInstructionCell class] forCellWithReuseIdentifier:kChoreographedPlayingClassViewControllerCellID];
    self.collectionView.backgroundColor = styleManager.themeBackgroundColor;
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.trackAttributionLogo addTarget:self action:@selector(trackAttributionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.tipButton addTarget:self action:@selector(tipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor = styleManager.themeBackgroundColor;
    
    self.trackArtist.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.trackArtwork.contentMode = UIViewContentModeScaleAspectFit;
    
    self.trackTitle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.instructorName.lineBreakMode = NSLineBreakByWordWrapping;
    self.instructorName.numberOfLines = 2;
    self.instructorName.textColor = styleManager.themeTextColor;
    self.instructorName.font = styleManager.verySmallBoldFont;
    
    self.instructorPicture.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.playPauseButton setTintColor:[UIColor whiteColor]];
    [self.playPauseButton setBackgroundImage:[UIImage imageWithColor:styleManager.maskColor] forState:UIControlStateNormal];
    self.playPauseButton.imageEdgeInsets = UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f);
    
    self.spacer.backgroundColor = styleManager.themeTextColor;
    
    self.tipButton.titleLabel.font = styleManager.verySmallBoldFont;
    [self.tipButton setTitle:NSLocalizedString(@"Tip Instructor", nil) forState:UIControlStateNormal];
    [self.tipButton setTitleColor:styleManager.themeTextColor forState:UIControlStateNormal];
    [self.tipButton setTitleColor:styleManager.themeBackgroundColor forState:UIControlStateHighlighted];
    [self.tipButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.tipButton setBackgroundImage:[UIImage imageWithColor:styleManager.themeTextColor] forState:UIControlStateHighlighted];
    self.tipButton.layer.borderWidth = 2.0f;
    self.tipButton.layer.borderColor = styleManager.themeTextColor.CGColor;
    
    self.trackArtist.textColor = styleManager.themeTextColor;
    self.trackArtist.font = styleManager.verySmallFont;
    
    self.trackAttributionLogo.tintColor = styleManager.themeTextColor;
    
    self.trackTitle.textColor = styleManager.themeTextColor;
    self.trackTitle.font = styleManager.verySmallBoldFont;
}

@end
