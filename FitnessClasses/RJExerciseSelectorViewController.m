//
//  RJExerciseSelectorViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/30/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJExerciseEquipmentOptionsViewController.h"
#import "RJExerciseSelectorViewController.h"
#import "RJParseExercise.h"
#import "RJParseExerciseEquipment.h"
#import "RJParseUtils.h"
#import "RJStyleManager.h"


@interface RJExerciseSelectorViewController () <RJExerciseEquipmentOptionsViewControllerDelegate, RJSingleSelectionViewControllerDataSource>

@property (nonatomic, strong) RJExerciseEquipmentOptionsViewController *equipmentOptionsViewController;
@property (nonatomic, strong) UIView *spacer;

@end


@implementation RJExerciseSelectorViewController

#pragma mark - Public Properties

- (RJExerciseEquipmentOptionsViewController *)equipmentOptionsViewController {
    if (!_equipmentOptionsViewController) {
        _equipmentOptionsViewController = [[RJExerciseEquipmentOptionsViewController alloc] initWithScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _equipmentOptionsViewController.exerciseEquipmentOptionsDelegate = self;
    }
    return _equipmentOptionsViewController;
}

- (void)setSelectedObject:(PFObject *)selectedObject {
    [super setSelectedObject:selectedObject];
    self.equipmentOptionsViewController.selectedEquipment = [(RJParseExercise *)selectedObject primaryEquipment];
}

- (UIView *)spacer {
    if (!_spacer) {
        _spacer = [[UIView alloc] initWithFrame:CGRectZero];
        _spacer.backgroundColor = [RJStyleManager sharedInstance].themeTextColor;
    }
    return _spacer;
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController titleForObject:(NSObject *)object {
    RJParseExercise *exercise = (RJParseExercise *)object;
    NSString *equipmentName = [NSString stringWithFormat:@"%@ ", exercise.primaryEquipment.name];
    return [exercise.title stringByReplacingOccurrencesOfString:equipmentName withString:@""];
}

#pragma mark - Private Protocols - RJExerciseEquipmentOptionsViewControllerDelegate

- (void)exerciseEquipmentOptionsViewController:(RJExerciseEquipmentOptionsViewController *)exerciseEquipmentOptionsViewController didSelectExerciseEquipment:(RJParseExerciseEquipment *)exerciseEquipment {
    [RJParseUtils fetchAllExercisesForPrimaryEquipment:exerciseEquipment completion:^(NSArray *exercises) {
        self.objects = exercises;
        self.tableView.contentOffset = CGPointZero;
        [self.tableView reloadData];
    }];
}

#pragma mark - Public Instance Methods

- (void)loadView {
    [super loadView];
    
    UIView *tableView = self.tableView;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *equipmentOptionsView = self.equipmentOptionsViewController.view;
    equipmentOptionsView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *spacer = self.spacer;
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:equipmentOptionsView];
    [self.view addSubview:spacer];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(tableView, equipmentOptionsView, spacer);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spacer]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[equipmentOptionsView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[equipmentOptionsView(50)][spacer(1)][tableView]|" options:0 metrics:nil views:views]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = nil;
    self.navigationItem.title = [NSLocalizedString(@"Pick Exercise", nil) uppercaseString];
}

@end
