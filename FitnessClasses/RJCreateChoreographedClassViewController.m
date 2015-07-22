//
//  RJCreateChoreographedClassViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJCreateChoreographedClassCollectionViewLayout.h"
#import "RJCreateChoreographedClassExerciseInstructionCell.h"
#import "RJCreateChoreographedClassViewController.h"
#import "RJCreateChoreographedClassTrackCell.h"
#import "RJLabelCell.h"
#import "RJParseExercise.h"
#import "RJParseExerciseInstruction.h"
#import "RJParseTrack.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJSingleSelectionViewController.h"
#import "RJSoundCloudAPIClient.h"
#import "RJSoundCloudTrack.h"
#import "RJStyleManager.h"
#import "RJTrackSelectorViewController.h"
#import "UIColor+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kLabelCellID = @"LabelCellID";
static NSString *const kExerciseInstructionCellID = @"ExerciseInstructionCellID";
static NSString *const kTrackCellID = @"TrackCellID";


@interface RJCreateChoreographedClassViewController () <RJCreateChoreographedClassExerciseInstructionCellDelegate, RJCreateChoreographedClassTrackCellDelegate, RJSingleSelectionViewControllerDataSource, RJSingleSelectionViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong, readonly) RJSingleSelectionViewController *categoryViewController;
@property (nonatomic, strong, readonly) RJSingleSelectionViewController *exerciseViewController;
@property (nonatomic, strong, readonly) RJSingleSelectionViewController *instructorViewController;

@end


@implementation RJCreateChoreographedClassViewController

@synthesize categoryViewController = _categoryViewController;
@synthesize exerciseViewController = _exerciseViewController;
@synthesize instructorViewController = _instructorViewController;

#pragma mark - Private Properties

- (RJSingleSelectionViewController *)categoryViewController {
    if (!_categoryViewController) {
        _categoryViewController = [[RJSingleSelectionViewController alloc] init];
        _categoryViewController.navigationItem.title = [NSLocalizedString(@"Pick Category", nil) uppercaseString];
        _categoryViewController.delegate = self;
        _categoryViewController.dataSource = self;
        [RJParseUtils fetchAllCategoriesWithCompletion:^(NSArray *equipment) {
            _categoryViewController.objects = equipment;
        }];
    }
    return _categoryViewController;
}

- (RJSingleSelectionViewController *)exerciseViewController {
    if (!_exerciseViewController) {
        _exerciseViewController = [[RJSingleSelectionViewController alloc] init];
        _exerciseViewController.navigationItem.title = [NSLocalizedString(@"Pick Exercise", nil) uppercaseString];
        _exerciseViewController.delegate = self;
        _exerciseViewController.dataSource = self;
        [RJParseUtils fetchAllExercisesWithCompletion:^(NSArray *exercises) {
            _exerciseViewController.objects = exercises;
        }];
    }
    return _exerciseViewController;
}

- (RJSingleSelectionViewController *)instructorViewController {
    if (!_instructorViewController) {
        _instructorViewController = [[RJSingleSelectionViewController alloc] init];
        _instructorViewController.navigationItem.title = [NSLocalizedString(@"Pick Instructor", nil) uppercaseString];
        _instructorViewController.delegate = self;
        _instructorViewController.dataSource = self;
        [RJParseUtils fetchAllInstructorsWithCompletion:^(NSArray *instructors) {
            _instructorViewController.objects = instructors;
        }];
    }
    return _instructorViewController;
}

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDelegate

- (void)singleSelectionViewController:(RJSingleSelectionViewController *)viewController didSelectObject:(NSObject *)object {
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

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSingleSelectionViewController *)viewController titleForObject:(NSObject *)object {
    if (viewController == self.instructorViewController) {
        RJParseUser *instructor = (RJParseUser *)object;
        return instructor.name;
    } else if (viewController == self.categoryViewController) {
        RJParseCategory *category = (RJParseCategory *)object;
        return category.name;
    } else {
        RJParseExercise *exercise = (RJParseExercise *)object;
        return exercise.title;
    }
}

#pragma mark - Private Protocols - RJCreateChoreographedClassExerciseInstructionCellDelegate

- (void)createChoreographedClassExerciseInstructionCellDidPressExerciseButton:(RJCreateChoreographedClassExerciseInstructionCell *)cell {
    self.exerciseViewController.view.tag = [self.exerciseInstructions indexOfObject:cell.instruction];
    [[self navigationController] pushViewController:self.exerciseViewController animated:YES];
}

- (void)createChoreographedClassExerciseInstructionCellDidPressTrashButton:(RJCreateChoreographedClassExerciseInstructionCell *)cell {
    if ([self.exerciseInstructions count] > 1) {
        NSUInteger index = [self.exerciseInstructions indexOfObject:cell.instruction];
        [self.exerciseInstructions removeObjectAtIndex:index];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:kRJCreateChoreographedClassViewControllerSectionExerciseInstructions]]];
    }
}

- (void)createChoreographedClassExerciseInstructionCellStartPointDidChange:(RJCreateChoreographedClassExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.instruction];
    RJParseExerciseInstruction *exerciseInstruction = self.exerciseInstructions[index];
    exerciseInstruction.startPoint = @(cell.startPoint);
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)createChoreographedClassExerciseInstructionCellQuantityTextFieldDidChange:(RJCreateChoreographedClassExerciseInstructionCell *)cell {
    NSUInteger index = [self.exerciseInstructions indexOfObject:cell.instruction];
    RJParseExerciseInstruction *exerciseInstruction = self.exerciseInstructions[index];
    exerciseInstruction.allLevelsQuantity = cell.quantityTextField.text;
}

#pragma mark - Private Protocols - RJCreateChoreographedClassTrackCellDelegate

- (void)createChoreographedClassTrackCellDownButtonPressed:(RJCreateChoreographedClassTrackCell *)cell {
    NSUInteger index = [self.tracks indexOfObject:cell.track];
    if (index != ([self.tracks count] - 1)) {
        [self.tracks exchangeObjectAtIndex:index withObjectAtIndex:(index+1)];
        NSIndexPath *initialIndexPath = [NSIndexPath indexPathForItem:index inSection:kRJCreateChoreographedClassViewControllerSectionTracks];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(index+1) inSection:kRJCreateChoreographedClassViewControllerSectionTracks];
        [self.collectionView moveItemAtIndexPath:initialIndexPath toIndexPath:newIndexPath];
    }
}

- (void)createChoreographedClassTrackCellUpButtonPressed:(RJCreateChoreographedClassTrackCell *)cell {
    NSUInteger index = [self.tracks indexOfObject:cell.track];
    if (index != 0) {
        [self.tracks exchangeObjectAtIndex:index withObjectAtIndex:(index-1)];
        NSIndexPath *initialIndexPath = [NSIndexPath indexPathForItem:index inSection:kRJCreateChoreographedClassViewControllerSectionTracks];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(index-1) inSection:kRJCreateChoreographedClassViewControllerSectionTracks];
        [self.collectionView moveItemAtIndexPath:initialIndexPath toIndexPath:newIndexPath];
    }
}

- (void)createChoreographedClassTrackCellTrashButtonPressed:(RJCreateChoreographedClassTrackCell *)cell {
    if ([self.tracks count] > 1) {
        NSUInteger index = [self.tracks indexOfObject:cell.track];
        [self.tracks removeObjectAtIndex:index];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:kRJCreateChoreographedClassViewControllerSectionTracks]]];
    }
}

- (void)createChoreographedClassTrackCellTrackButtonPressed:(RJCreateChoreographedClassTrackCell *)cell {
    RJTrackSelectorViewController *trackSelector = [[RJTrackSelectorViewController alloc] init];
    trackSelector.delegate = self;
    trackSelector.view.tag = [self.tracks indexOfObject:cell.track];
    [[self navigationController] pushViewController:trackSelector animated:YES];
}

#pragma mark - Private Protocols - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumRJCreateChoreographedClassViewControllerSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    
    RJCreateChoreographedClassViewControllerSection classSection = section;
    switch (classSection) {
        case kRJCreateChoreographedClassViewControllerSectionName:
            numberOfItems = 1;
            break;
        case kRJCreateChoreographedClassViewControllerSectionInstructor:
            numberOfItems = 1;
            break;
        case kRJCreateChoreographedClassViewControllerSectionCategory:
            numberOfItems = 1;
            break;
        case kRJCreateChoreographedClassViewControllerSectionAddTrack:
            numberOfItems = 1;
            break;
        case kRJCreateChoreographedClassViewControllerSectionAddExerciseInstruction:
            numberOfItems = 1;
            break;
        case kRJCreateChoreographedClassViewControllerSectionExerciseInstructions:
            numberOfItems = [self.exerciseInstructions count];
            break;
        case kRJCreateChoreographedClassViewControllerSectionTracks:
            numberOfItems = [self.tracks count];
            break;
        case kRJCreateChoreographedClassViewControllerSectionCreate:
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
    
    RJCreateChoreographedClassViewControllerSection classSection = indexPath.section;
    switch (classSection) {
        case kRJCreateChoreographedClassViewControllerSectionName: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextField;
            labelCell.accessoryView.image = nil;
            labelCell.textField.text = self.name;
            labelCell.textField.delegate = self;
            labelCell.textField.placeholder = NSLocalizedString(@"Name", nil);
            labelCell.textField.font = styleManager.smallBoldFont;
            labelCell.textField.textAlignment = NSTextAlignmentLeft;
            labelCell.textField.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionInstructor: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = [UIImage imageNamed:@"forwardIcon"];
            labelCell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
            RJParseUser *instructor = (RJParseUser *)self.instructorViewController.selectedObject;
            labelCell.textLabel.text = instructor ? instructor.name : NSLocalizedString(@"Instructor", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionCategory: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = [UIImage imageNamed:@"forwardIcon"];
            labelCell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
            RJParseCategory *category = (RJParseCategory *)self.categoryViewController.selectedObject;
            labelCell.textLabel.text = category ? category.name : NSLocalizedString(@"Category", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionAddTrack: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.text = NSLocalizedString(@"Add Track", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionAddExerciseInstruction: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.text = NSLocalizedString(@"Add Exercise Instruction", nil);
            labelCell.textLabel.font = styleManager.smallBoldFont;
            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
            labelCell.textLabel.textColor = styleManager.themeTextColor;
            labelCell.topBorder.backgroundColor = styleManager.themeTextColor;
            labelCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            cell = labelCell;
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionExerciseInstructions: {
            RJCreateChoreographedClassExerciseInstructionCell *instructionCell = [collectionView dequeueReusableCellWithReuseIdentifier:kExerciseInstructionCellID forIndexPath:indexPath];
            instructionCell.delegate = self;
            instructionCell.topBorder.backgroundColor = styleManager.themeTextColor;
            instructionCell.bottomBorder.backgroundColor = styleManager.themeTextColor;
            instructionCell.buttonsAreaBackground.backgroundColor = styleManager.tintLightGrayColor;
            RJParseExerciseInstruction *instruction = self.exerciseInstructions[indexPath.item];
            instructionCell.instruction = instruction;
            NSString *exerciseButtonTitle = instruction.exercise ? instruction.exercise.title : NSLocalizedString(@"Exercise", nil);
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
            instructionCell.startPointTextField.textAlignment = NSTextAlignmentCenter;
            instructionCell.startPointTextField.font = styleManager.smallFont;
            instructionCell.backgroundView.backgroundColor = [self colorForObject:instruction];
            cell = instructionCell;
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionTracks: {
            RJCreateChoreographedClassTrackCell *trackCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTrackCellID forIndexPath:indexPath];
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
        case kRJCreateChoreographedClassViewControllerSectionCreate: {
            RJLabelCell *labelCell = (RJLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
            labelCell.selectedBackgroundView.backgroundColor = styleManager.tintLightGrayColor;
            labelCell.style = kRJLabelCellStyleTextLabel;
            labelCell.accessoryView.image = nil;
            labelCell.textLabel.text = NSLocalizedString(@"Create Class", nil);
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

#pragma mark - Private Protocols - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RJCreateChoreographedClassViewControllerSection classSection = indexPath.section;
    switch (classSection) {
        case kRJCreateChoreographedClassViewControllerSectionName: {
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionInstructor: {
            [[self navigationController] pushViewController:self.instructorViewController animated:YES];
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionCategory: {
            [[self navigationController] pushViewController:self.categoryViewController animated:YES];
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionAddTrack: {
            RJParseTrack *newTrack = [RJParseTrack object];
            [self.tracks addObject:newTrack];
            NSUInteger newIndex = [self.tracks indexOfObject:newTrack];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:kRJCreateChoreographedClassViewControllerSectionTracks]]];
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionAddExerciseInstruction: {
            RJParseExerciseInstruction *newInstruction = [RJParseExerciseInstruction object];
            RJParseExerciseInstruction *lastInstruction = [[self sortedExerciseInstructions] lastObject];
            newInstruction.startPoint = @(([lastInstruction.startPoint integerValue] + 60));
            [self.exerciseInstructions addObject:newInstruction];
            NSUInteger newIndex = [self.exerciseInstructions indexOfObject:newInstruction];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:kRJCreateChoreographedClassViewControllerSectionExerciseInstructions]]];
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionExerciseInstructions: {
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionTracks: {
            break;
        }
        case kRJCreateChoreographedClassViewControllerSectionCreate: {
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

#pragma mark - Private Instance Methods

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
    exerciseInstruction.startPoint = @(0);
    _exerciseInstructions = [[NSMutableArray alloc] initWithObjects:exerciseInstruction, nil];
    RJParseTrack *track = [RJParseTrack object];
    _tracks = [[NSMutableArray alloc] initWithObjects:track, nil];
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
    RJCreateChoreographedClassCollectionViewLayout *layout = [[RJCreateChoreographedClassCollectionViewLayout alloc] init];
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
    
    self.navigationItem.title = [NSLocalizedString(@"Create Choreographed Workout", nil) uppercaseString];
    
    [self.collectionView registerClass:[RJLabelCell class] forCellWithReuseIdentifier:kLabelCellID];
    [self.collectionView registerClass:[RJCreateChoreographedClassExerciseInstructionCell class] forCellWithReuseIdentifier:kExerciseInstructionCellID];
    [self.collectionView registerClass:[RJCreateChoreographedClassTrackCell class] forCellWithReuseIdentifier:kTrackCellID];
    
    self.collectionView.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
}

@end
