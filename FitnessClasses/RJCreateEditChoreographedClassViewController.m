//
//  RJCreateEditChoreographedClassViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJCategorySelectorViewController.h"
#import "RJCreateEditChoreographedClassCollectionViewLayout.h"
#import "RJCreateEditChoreographedClassExerciseInstructionCell.h"
#import "RJCreateEditChoreographedClassTimeline.h"
#import "RJCreateEditChoreographedClassViewController.h"
#import "RJCreateEditChoreographedClassTrackCell.h"
#import "RJExerciseSelectorViewController.h"
#import "RJInsetLabel.h"
#import "RJInstructorSelectorViewController.h"
#import "RJLabelCell.h"
#import "RJParseExercise.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseTrack.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJSoundCloudAPIClient.h"
#import "RJSoundCloudTrack.h"
#import "RJStyleManager.h"
#import "RJTrackSelectorViewController.h"
#import "UIColor+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kLabelCellID = @"LabelCellID";
static NSString *const kExerciseInstructionCellID = @"ExerciseInstructionCellID";
static NSString *const kTimelineReusableViewID = @"TimelineReusableViewID";
static NSString *const kTrackCellID = @"TrackCellID";


@interface RJCreateEditChoreographedClassViewController () <RJCreateEditChoreographedClassExerciseInstructionCellDelegate, RJCreateChoreographedClassTrackCellDelegate, RJSingleSelectionViewControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong, readonly) RJCategorySelectorViewController *categoryViewController;
@property (nonatomic, strong, readonly) RJExerciseSelectorViewController *exerciseViewController;
@property (nonatomic, strong, readonly) RJInstructorSelectorViewController *instructorViewController;

@property (nonatomic, strong) NSIndexPath *movingIndexPath;
@property (nonatomic, strong) RJCreateEditChoreographedClassExerciseInstructionCell *movingCellSnapshot;

@property (nonatomic, assign, getter=isEditMode) BOOL editMode;

@property (nonatomic, strong) NSString *name;

@end


@implementation RJCreateEditChoreographedClassViewController

@synthesize categoryViewController = _categoryViewController;
@synthesize exerciseViewController = _exerciseViewController;
@synthesize instructorViewController = _instructorViewController;

#pragma mark - Public Properties

- (void)setKlass:(RJParseClass *)klass {
    _klass = klass;
    self.name = _klass.name;
    _exerciseInstructions = [[NSMutableArray alloc] initWithArray:_klass.exerciseInstructions];
    _tracks = [[NSMutableArray alloc] initWithArray:_klass.tracks];
    self.instructorViewController.selectedObject = _klass.instructor;
    self.categoryViewController.selectedObject = _klass.category;
}

#pragma mark - Private Properties

- (RJCategorySelectorViewController *)categoryViewController {
    if (!_categoryViewController) {
        _categoryViewController = [[RJCategorySelectorViewController alloc] init];
        _categoryViewController.incrementalSearchEnabled = YES;
        _categoryViewController.delegate = self;
    }
    return _categoryViewController;
}

- (RJExerciseSelectorViewController *)exerciseViewController {
    if (!_exerciseViewController) {
        _exerciseViewController = [[RJExerciseSelectorViewController alloc] init];
        _exerciseViewController.incrementalSearchEnabled = YES;
        _exerciseViewController.delegate = self;
    }
    return _exerciseViewController;
}

- (RJInstructorSelectorViewController *)instructorViewController {
    if (!_instructorViewController) {
        _instructorViewController = [[RJInstructorSelectorViewController alloc] init];
        _instructorViewController.incrementalSearchEnabled = YES;
        _instructorViewController.delegate = self;
    }
    return _instructorViewController;
}

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDelegate

- (void)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController didSelectObject:(NSObject *)object {
    if (viewController == self.instructorViewController) {
        [self.collectionView reloadData];
    } else if (viewController == self.categoryViewController) {
        [self.collectionView reloadData];
    } else if ([viewController isKindOfClass:[RJTrackSelectorViewController class]]) {
        RJParseTrack *track = self.tracks[viewController.view.tag];
        RJSoundCloudTrack *soundCloudTrack = (RJSoundCloudTrack *)object;
        track.artist = soundCloudTrack.artist;
        track.length = @((NSInteger)soundCloudTrack.length);
        track.soundCloudTrackID = soundCloudTrack.trackID;
        track.title = soundCloudTrack.title;
        track.artworkURL = soundCloudTrack.artworkURL;
        track.streamURL = soundCloudTrack.streamURL;
        track.permalinkURL = soundCloudTrack.permalinkURL;
        [self.collectionView reloadData];
    } else if (viewController == self.exerciseViewController) {
        RJParseExerciseInstruction *instruction = self.exerciseInstructions[viewController.view.tag];
        instruction.exercise = (RJParseExercise *)object;
        [self.collectionView reloadData];
    }
}

#pragma mark - Private Protocols - RJCreateEditChoreographedClassExerciseInstructionCellDelegate

- (void)createEditChoreographedClassExerciseInstructionCellDidPressDuplicateButton:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell {
    NSArray *sortedExerciseInstructions = [self sortedExerciseInstructions];
    
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.instruction];
    RJParseExerciseInstruction *exerciseInstruction = self.exerciseInstructions[index];
    RJParseExerciseInstruction *newExerciseInstruction = [RJParseExerciseInstruction object];
    newExerciseInstruction.exercise = exerciseInstruction.exercise;
    newExerciseInstruction.allLevelsQuantity = exerciseInstruction.allLevelsQuantity;
    NSInteger bufferForNewInstructionStartPoint = [self bufferForNewInstructionStartPointWithSortedExerciseInstructions:sortedExerciseInstructions];
    [newExerciseInstruction setRoundableStartPoint:@([exerciseInstruction.startPoint integerValue] + bufferForNewInstructionStartPoint)];
    
    NSUInteger newIndex = (index + 1);
    [self.exerciseInstructions insertObject:newExerciseInstruction atIndex:newIndex];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions]]];
}

- (void)createEditChoreographedClassExerciseInstructionCellDidPressExerciseButton:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell {
    self.exerciseViewController.view.tag = [self.exerciseInstructions indexOfObject:cell.instruction];
    self.exerciseViewController.selectedObject = cell.instruction.exercise;
    [[self navigationController] pushViewController:self.exerciseViewController animated:YES];
}

- (void)createEditChoreographedClassExerciseInstructionCellDidPressTrashButton:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell {
    if ([self.exerciseInstructions count] > 1) {
        NSUInteger index = [self.exerciseInstructions indexOfObject:cell.instruction];
        [self.exerciseInstructions removeObjectAtIndex:index];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions]]];
    }
}

- (void)createEditChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:(RJCreateEditChoreographedClassExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.instruction];
    RJParseExerciseInstruction *exerciseInstruction = self.exerciseInstructions[index];
    exerciseInstruction.allLevelsQuantity = cell.quantityTextField.text;
}

#pragma mark - Private Protocols - RJCreateChoreographedClassTrackCellDelegate

- (void)createEditChoreographedClassTrackCellDownButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell {
    NSUInteger index = [self.tracks indexOfObject:cell.track];
    if (index != ([self.tracks count] - 1)) {
        [self.tracks exchangeObjectAtIndex:index withObjectAtIndex:(index+1)];
        NSIndexPath *initialIndexPath = [NSIndexPath indexPathForItem:index inSection:kRJCreateEditChoreographedClassViewControllerSectionTracks];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(index+1) inSection:kRJCreateEditChoreographedClassViewControllerSectionTracks];
        [self.collectionView moveItemAtIndexPath:initialIndexPath toIndexPath:newIndexPath];
    }
}

- (void)createEditChoreographedClassTrackCellUpButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell {
    NSUInteger index = [self.tracks indexOfObject:cell.track];
    if (index != 0) {
        [self.tracks exchangeObjectAtIndex:index withObjectAtIndex:(index-1)];
        NSIndexPath *initialIndexPath = [NSIndexPath indexPathForItem:index inSection:kRJCreateEditChoreographedClassViewControllerSectionTracks];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(index-1) inSection:kRJCreateEditChoreographedClassViewControllerSectionTracks];
        [self.collectionView moveItemAtIndexPath:initialIndexPath toIndexPath:newIndexPath];
    }
}

- (void)createEditChoreographedClassTrackCellTrashButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell {
    if ([self.tracks count] > 1) {
        NSUInteger index = [self.tracks indexOfObject:cell.track];
        [self.tracks removeObjectAtIndex:index];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:kRJCreateEditChoreographedClassViewControllerSectionTracks]]];
    }
}

- (void)createEditChoreographedClassTrackCellTrackButtonPressed:(RJCreateEditChoreographedClassTrackCell *)cell {
    RJTrackSelectorViewController *trackSelector = [[RJTrackSelectorViewController alloc] init];
    trackSelector.delegate = self;
    trackSelector.view.tag = [self.tracks indexOfObject:cell.track];
    [[self navigationController] pushViewController:trackSelector animated:YES];
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumRJCreateEditChoreographedClassViewControllerSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    
    RJCreateEditChoreographedClassViewControllerSection classSection = section;
    switch (classSection) {
        case kRJCreateEditChoreographedClassViewControllerSectionName:
            numberOfItems = 1;
            break;
        case kRJCreateEditChoreographedClassViewControllerSectionInstructor:
            numberOfItems = 1;
            break;
        case kRJCreateEditChoreographedClassViewControllerSectionCategory:
            numberOfItems = 1;
            break;
        case kRJCreateEditChoreographedClassViewControllerSectionAddTrack:
            numberOfItems = 1;
            break;
        case kRJCreateEditChoreographedClassViewControllerSectionAddExerciseInstruction:
            numberOfItems = 1;
            break;
        case kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions:
            numberOfItems = [self.exerciseInstructions count];
            break;
        case kRJCreateEditChoreographedClassViewControllerSectionTracks:
            numberOfItems = [self.tracks count];
            break;
        case kRJCreateEditChoreographedClassViewControllerSectionCreate:
            numberOfItems = 1;
            break;
        default:
            break;
    }
    
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    RJCreateEditChoreographedClassViewControllerSection classSection = indexPath.section;
    switch (classSection) {
        case kRJCreateEditChoreographedClassViewControllerSectionName: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextField;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
            labelCell.textField.text = self.name;
            labelCell.textField.delegate = self;
            labelCell.textField.placeholder = NSLocalizedString(@"Name", nil);
            labelCell.textField.font = styleManager.smallBoldFont;
            labelCell.textField.textAlignment = NSTextAlignmentCenter;
            labelCell.textField.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionInstructor: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = [UIImage imageNamed:@"forwardIcon"];
            labelCell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
            RJParseUser *instructor = (RJParseUser *)self.instructorViewController.selectedObject;
            labelCell.textLabel.insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 20.0f);
            labelCell.textLabel.text = instructor ? instructor.name : NSLocalizedString(@"Instructor", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionCategory: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = [UIImage imageNamed:@"forwardIcon"];
            labelCell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
            RJParseCategory *category = (RJParseCategory *)self.categoryViewController.selectedObject;
            labelCell.textLabel.insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 20.0f);
            labelCell.textLabel.text = category ? category.name : NSLocalizedString(@"Category", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionAddTrack: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
            labelCell.textLabel.text = NSLocalizedString(@"Add Track", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionAddExerciseInstruction: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.text = NSLocalizedString(@"Add Exercise Instruction", nil);
            labelCell.textLabel.insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions: {
            RJCreateEditChoreographedClassExerciseInstructionCell *instructionCell = [collectionView dequeueReusableCellWithReuseIdentifier:kExerciseInstructionCellID forIndexPath:indexPath];
            instructionCell.delegate = self;
            [self configureCreateEditExerciseInstructionCell:instructionCell atIndexPath:indexPath];
            cell = instructionCell;
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionTracks: {
            RJCreateEditChoreographedClassTrackCell *trackCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTrackCellID forIndexPath:indexPath];
            trackCell.delegate = self;
            RJParseTrack *track = self.tracks[indexPath.item];
            trackCell.track = track;
            
            NSInteger startPoint = 0;
            for (NSInteger i = 0; i < indexPath.item; i++) {
                RJParseTrack *previousTrack = self.tracks[i];
                startPoint += [previousTrack.length integerValue];
            }
            trackCell.startPoint = startPoint;
            
            NSString *trackButtonTitle = track.title ? track.title : NSLocalizedString(@"Track", nil);
            [trackCell.trackButton setTitle:trackButtonTitle forState:UIControlStateNormal];
            trackCell.trackButton.titleLabel.font = styleManager.smallBoldFont;
            [trackCell.trackButton setTitleColor:styleManager.themeTextColor forState:UIControlStateNormal];
            trackCell.trackButton.titleLabel.numberOfLines = 0;
            trackCell.trackButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            trackCell.trackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            trackCell.timingLabel.textAlignment = NSTextAlignmentCenter;
            trackCell.timingLabel.font = styleManager.smallFont;
            trackCell.buttonsAreaBackground.backgroundColor = styleManager.tintLightGrayColor;
            trackCell.upButton.contentMode = UIViewContentModeScaleAspectFit;
            [trackCell.upButton setImage:[UIImage tintableImageNamed:@"upIcon"] forState:UIControlStateNormal];
            trackCell.upButton.tintColor = styleManager.themeTextColor;
            trackCell.upButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            [trackCell.downButton setImage:[UIImage tintableImageNamed:@"downIcon"] forState:UIControlStateNormal];
            trackCell.downButton.contentMode = UIViewContentModeScaleAspectFit;
            trackCell.downButton.tintColor = styleManager.themeTextColor;
            trackCell.downButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            [trackCell.trashButton setImage:[UIImage tintableImageNamed:@"trashIcon"] forState:UIControlStateNormal];
            trackCell.trashButton.contentMode = UIViewContentModeScaleAspectFit;
            trackCell.trashButton.tintColor = styleManager.themeTextColor;
            trackCell.trashButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
            trackCell.topBorder.backgroundColor = styleManager.themeTextColor;
            trackCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            trackCell.backgroundView.backgroundColor = [self colorForObject:track];
            cell = trackCell;
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionCreate: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
            labelCell.textLabel.text = self.klass ? NSLocalizedString(@"Update Class", nil) : NSLocalizedString(@"Create Class", nil);
            labelCell.textLabel.textColor = styleManager.tintBlueColor;
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:[RJCreateEditChoreographedClassTimeline kind]]) {
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        
        RJCreateEditChoreographedClassTimeline *timeline = [collectionView dequeueReusableSupplementaryViewOfKind:[RJCreateEditChoreographedClassTimeline kind] withReuseIdentifier:kTimelineReusableViewID forIndexPath:indexPath];
        timeline.backgroundColor = [UIColor clearColor];
        timeline.tintColor = styleManager.themeTextColor;
        timeline.labelColor = styleManager.themeBackgroundColor;
        timeline.labelBackgroundColor = styleManager.themeTextColor;
        timeline.font = styleManager.verySmallBoldFont;
        timeline.labelInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
        [timeline setNeedsDisplay];
        reusableView = timeline;
    }
    return reusableView;
}

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJCreateEditChoreographedClassViewControllerSection classSection = indexPath.section;
    switch (classSection) {
        case kRJCreateEditChoreographedClassViewControllerSectionName: {
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionInstructor: {
            [[self navigationController] pushViewController:self.instructorViewController animated:YES];
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionCategory: {
            [[self navigationController] pushViewController:self.categoryViewController animated:YES];
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionAddTrack: {
            RJParseTrack *newTrack = [RJParseTrack object];
            [self.tracks addObject:newTrack];
            NSUInteger newIndex = [self.tracks indexOfObject:newTrack];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:kRJCreateEditChoreographedClassViewControllerSectionTracks]]];
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionAddExerciseInstruction: {
            NSArray *sortedExerciseInstructions = [self sortedExerciseInstructions];
            NSInteger newStartPointBuffer = [self bufferForNewInstructionStartPointWithSortedExerciseInstructions:sortedExerciseInstructions];
            RJParseExerciseInstruction *newInstruction = [RJParseExerciseInstruction object];
            RJParseExerciseInstruction *lastInstruction = [sortedExerciseInstructions lastObject];
            [newInstruction setRoundableStartPoint:@([lastInstruction.startPoint integerValue] + newStartPointBuffer)];
            [self.exerciseInstructions addObject:newInstruction];
            NSUInteger newIndex = [self.exerciseInstructions indexOfObject:newInstruction];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions]]];
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions: {
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionTracks: {
            break;
        }
        case kRJCreateEditChoreographedClassViewControllerSectionCreate: {
            RJParseCategory *category = (RJParseCategory *)self.categoryViewController.selectedObject;
            RJParseUser *instructor = (RJParseUser *)self.instructorViewController.selectedObject;
            BOOL validates = (self.name && category && instructor && ([self.exerciseInstructions count] > 0) && ([self.tracks count] > 0));
            for (RJParseExerciseInstruction *instruction in self.exerciseInstructions) {
                if (!instruction.exercise || !instruction.allLevelsQuantity || !instruction.startPoint) {
                    validates = NO;
                    break;
                }
            }
            for (RJParseTrack *track in self.tracks) {
                if (!track.soundCloudTrackID) {
                    validates = NO;
                }
            }
            
            if (validates) {
                [SVProgressHUD show];
                if (self.klass) {
                    [RJParseUtils updateClass:self.klass withName:self.name classType:kRJParseClassTypeChoreographed category:category instructor:instructor tracks:self.tracks exerciseInstructions:[self sortedExerciseInstructions] completion:^(BOOL success) {
                        if (success) {
                            [SVProgressHUD showSuccessWithStatus:nil];
                            [[self navigationController] popViewControllerAnimated:YES];
                        } else {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error. Try again!", nil)];
                        }
                    }];
                } else {
                    [RJParseUtils createClassWithName:self.name classType:kRJParseClassTypeChoreographed category:category instructor:instructor tracks:self.tracks exerciseInstructions:[self sortedExerciseInstructions] completion:^(BOOL success) {
                        if (success) {
                            self.name = nil;
                            _categoryViewController = nil;
                            _exerciseViewController = nil;
                            _instructorViewController = nil;
                            [self preloadSupplementaryViewControllers];
                            [self resetExerciseInstructionsAndTracks];
                            [self.collectionView reloadData];
                            [SVProgressHUD showSuccessWithStatus:nil];
                        } else {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error. Try again!", nil)];
                        }
                    }];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Missing info", nil)];
            }
            break;
        }
        default:
            break;
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - Private Protocols - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.movingIndexPath) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Private Instance Methods

- (CGFloat)bufferForNewInstructionStartPointWithSortedExerciseInstructions:(NSArray *)sortedExerciseInstructions {
    NSInteger newStartPointBuffer = 0;
    NSInteger numberOfExerciseInstructions = [sortedExerciseInstructions count];
    if (numberOfExerciseInstructions > 1) {
        RJParseExerciseInstruction *lastInstruction = [sortedExerciseInstructions lastObject];
        RJParseExerciseInstruction *nextToLastInstruction = sortedExerciseInstructions[(numberOfExerciseInstructions - 2)];
        newStartPointBuffer = ([lastInstruction.startPoint integerValue] - [nextToLastInstruction.startPoint integerValue]);
    } else {
        newStartPointBuffer = 60;
    }
    return newStartPointBuffer;
}

- (void)configureCreateEditExerciseInstructionCell:(RJCreateEditChoreographedClassExerciseInstructionCell *)instructionCell atIndexPath:(NSIndexPath *)indexPath {
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    instructionCell.topBorder.backgroundColor = styleManager.themeTextColor;
    instructionCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
    instructionCell.buttonsAreaBackground.backgroundColor = styleManager.tintLightGrayColor;
    RJParseExerciseInstruction *instruction = self.exerciseInstructions[indexPath.item];
    instructionCell.instruction = instruction;
    NSString *exerciseButtonTitle = instruction.exercise ? instruction.exercise.title : NSLocalizedString(@"Exercise", nil);
    instructionCell.exerciseButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [instructionCell.exerciseButton setTitle:exerciseButtonTitle forState:UIControlStateNormal];
    [instructionCell.exerciseButton setTitleColor:styleManager.themeTextColor forState:UIControlStateNormal];
    instructionCell.exerciseButton.titleLabel.font = styleManager.smallBoldFont;
    instructionCell.exerciseButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    instructionCell.quantityTextField.placeholder = NSLocalizedString(@"Quantity", nil);
    instructionCell.quantityTextField.text = instruction.allLevelsQuantity;
    instructionCell.quantityTextField.textAlignment = NSTextAlignmentCenter;
    instructionCell.quantityTextField.textColor = styleManager.themeTextColor;
    instructionCell.quantityTextField.font = styleManager.smallFont;
    instructionCell.quantityTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [instructionCell.trashButton setImage:[UIImage tintableImageNamed:@"trashIcon"] forState:UIControlStateNormal];
    instructionCell.trashButton.contentMode = UIViewContentModeScaleAspectFit;
    instructionCell.trashButton.tintColor = styleManager.themeTextColor;
    instructionCell.trashButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    [instructionCell.duplicateButton setImage:[UIImage tintableImageNamed:@"duplicateIcon"] forState:UIControlStateNormal];
    instructionCell.duplicateButton.contentMode = UIViewContentModeScaleAspectFit;
    instructionCell.duplicateButton.tintColor = styleManager.themeTextColor;
    instructionCell.duplicateButton.contentEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    instructionCell.startPointLabel.textAlignment = NSTextAlignmentCenter;
    instructionCell.startPointLabel.font = styleManager.smallFont;
    instructionCell.startPointLabel.textColor = styleManager.themeTextColor;
    instructionCell.backgroundView.backgroundColor = [self colorForObject:instruction];
}

- (UIColor *)colorForObject:(NSObject *)object {
    NSString *memoryAddress = [NSString stringWithFormat:@"%p", object];
    NSString *rawNumericMemoryAddress = [[memoryAddress componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSString *numericMemoryAddress = [NSString stringWithFormat:@"%lu", (unsigned long)[rawNumericMemoryAddress floatValue]];
    
    NSMutableString *maxValueString = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < numericMemoryAddress.length; i++) {
        [maxValueString appendString:@"9"];
    }
    
    CGFloat distance = ((CGFloat)numericMemoryAddress.hash/(CGFloat)maxValueString.hash);
    UIColor *minimumColor = [UIColor colorWithRed:224.0f/255.0f green:53.0f/255.0f blue:53.0f/255.0f alpha:1.0f];
    UIColor *maximumColor = [UIColor colorWithRed:73.0f/255.0f green:190.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    
    return [UIColor colorForDistance:distance betweenColor:minimumColor andColor:maximumColor];
}

- (void)resetExerciseInstructionsAndTracks {
    RJParseExerciseInstruction *exerciseInstruction = [RJParseExerciseInstruction object];
    [exerciseInstruction setRoundableStartPoint:@(0)];
    _exerciseInstructions = [[NSMutableArray alloc] initWithObjects:exerciseInstruction, nil];
    RJParseTrack *track = [RJParseTrack object];
    _tracks = [[NSMutableArray alloc] initWithObjects:track, nil];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPressGestureRecognizer locationInView:self.collectionView];
        self.movingIndexPath = [self.collectionView indexPathForItemAtPoint:point];
        if ((self.movingIndexPath.section == kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions) ||
            !self.movingIndexPath)
        {
            if (!self.movingIndexPath) {
                RJParseExerciseInstruction *newInstruction = [RJParseExerciseInstruction object];
                CGPoint location = [longPressGestureRecognizer locationInView:self.collectionView];
                [newInstruction setRoundableStartPoint:@([RJCreateEditChoreographedClassCollectionViewLayout startPointForOriginY:location.y])];
                [self.exerciseInstructions addObject:newInstruction];
                NSUInteger newIndex = [self.exerciseInstructions indexOfObject:newInstruction];
                self.movingIndexPath = [NSIndexPath indexPathForItem:newIndex inSection:kRJCreateEditChoreographedClassViewControllerSectionExerciseInstructions];
                [self.collectionView insertItemsAtIndexPaths:@[self.movingIndexPath]];
            }
            
            RJCreateEditChoreographedClassExerciseInstructionCell *movingCell = (RJCreateEditChoreographedClassExerciseInstructionCell *)[self.collectionView cellForItemAtIndexPath:self.movingIndexPath];
            self.movingCellSnapshot = [[RJCreateEditChoreographedClassExerciseInstructionCell alloc] initWithFrame:movingCell.frame];
            [self configureCreateEditExerciseInstructionCell:self.movingCellSnapshot atIndexPath:self.movingIndexPath];
            
            CGFloat alphaForMoving = 0.4f;
            movingCell.alpha = alphaForMoving;
            self.movingCellSnapshot.alpha = alphaForMoving;
            
            [self.collectionView addSubview:self.movingCellSnapshot];
        } else {
            self.movingIndexPath = nil;
        }
    } else if ((longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) && self.movingIndexPath) {
        CGPoint location = [longPressGestureRecognizer locationInView:self.collectionView];
        RJParseExerciseInstruction *instruction = self.exerciseInstructions[self.movingIndexPath.item];
        [instruction setRoundableStartPoint:@([RJCreateEditChoreographedClassCollectionViewLayout startPointForOriginY:location.y])];
        RJCreateEditChoreographedClassExerciseInstructionCell *movingCell = (RJCreateEditChoreographedClassExerciseInstructionCell *)[self.collectionView cellForItemAtIndexPath:self.movingIndexPath];
        movingCell.alpha = 1.0f;
        self.movingIndexPath = nil;
        [self.collectionView reloadData];
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.movingCellSnapshot removeFromSuperview];
        self.movingCellSnapshot = nil;
    } else if ((longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) && self.movingIndexPath) {
        CGRect movingCellSnapshotFrame = self.movingCellSnapshot.frame;
        movingCellSnapshotFrame.origin.y = [longPressGestureRecognizer locationInView:self.collectionView].y;
        NSInteger duration = [RJCreateEditChoreographedClassCollectionViewLayout startPointForOriginY:CGRectGetMinY(movingCellSnapshotFrame)];
        self.movingCellSnapshot.startPointLabel.text = [NSString hhmmaaForTotalSeconds:duration];
        self.movingCellSnapshot.frame = movingCellSnapshotFrame;
        
        CGFloat topOfScreen = self.collectionView.contentOffset.y;
        CGFloat movingCellSnapshotOriginY = CGRectGetMinY(self.movingCellSnapshot.frame);
        if (movingCellSnapshotOriginY < topOfScreen) {
            self.collectionView.contentOffset = CGPointMake(0.0f, movingCellSnapshotOriginY);
        } else {
            CGFloat collectionViewBottomInset = self.collectionView.contentInset.bottom;
            CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.frame);
            CGFloat bottomOfScreen = (topOfScreen + collectionViewHeight - collectionViewBottomInset);
            CGFloat movingCellSnapshotMaxY = CGRectGetMaxY(self.movingCellSnapshot.frame);
            if (movingCellSnapshotMaxY > bottomOfScreen) {
                CGFloat newContentOffsetY = (movingCellSnapshotMaxY - collectionViewHeight + collectionViewBottomInset);
                self.collectionView.contentOffset = CGPointMake(0.0f, newContentOffsetY);
            }
        }
    }
}

- (void)preloadSupplementaryViewControllers {
    [self categoryViewController];
    [self exerciseViewController];
    [self instructorViewController];
}
- (NSArray *)sortedExerciseInstructions {
    return [self.exerciseInstructions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startPoint" ascending:YES]]];
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    RJCreateEditChoreographedClassCollectionViewLayout *layout = [[RJCreateEditChoreographedClassCollectionViewLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self resetExerciseInstructionsAndTracks];
        [self preloadSupplementaryViewControllers];
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 44.0f, 0.0f);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, insets)) {
        self.collectionView.contentInset = insets;
        self.collectionView.scrollIndicatorInsets = insets;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSLocalizedString(@"Create Workout", nil) uppercaseString];
    
    [self.collectionView registerClass:[RJCreateEditChoreographedClassTimeline class] forSupplementaryViewOfKind:[RJCreateEditChoreographedClassTimeline kind] withReuseIdentifier:kTimelineReusableViewID];
    [self.collectionView registerClass:[RJLabelCell class] forCellWithReuseIdentifier:kLabelCellID];
    [self.collectionView registerClass:[RJCreateEditChoreographedClassExerciseInstructionCell class] forCellWithReuseIdentifier:kExerciseInstructionCellID];
    [self.collectionView registerClass:[RJCreateEditChoreographedClassTrackCell class] forCellWithReuseIdentifier:kTrackCellID];
    
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    longPressGestureRecognizer.minimumPressDuration = 0.2;
    longPressGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
}

@end
