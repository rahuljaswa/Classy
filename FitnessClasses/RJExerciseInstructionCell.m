//
//  RJExerciseInstructionCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJClassImageCacheEntity.h"
#import "RJExerciseInstructionCell.h"
#import "RJInsetLabel.h"
#import "RJParseExercise.h"
#import "RJParseExerciseInstruction.h"
#import "RJStyleManager.h"
#import "UIImage+RJAdditions.h"
#import "UIImageView+FastImageCache.h"

static const CGFloat kMarginTop = 10.0f;
static const CGFloat kMarginBottom = 10.0f;
static const CGFloat kTitleElementsHeight = 44.0f;
static const CGFloat kButtonElementsWidth = 50.0f;
static const CGFloat kSpacerHeight = 0.5f;


@interface RJExerciseInstructionCell ()

@property (nonatomic, assign, getter=hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJExerciseInstructionCell

#pragma mark - Public Properties

- (void)setExerciseInstruction:(RJParseExerciseInstruction *)exerciseInstruction {
    _exerciseInstruction = exerciseInstruction;
    
    self.quantityLabelAllLevels.text = _exerciseInstruction.allLevelsQuantity;
    
    self.quantityLabelAdvanced.attributedText = [self attributedStringForLabelText:NSLocalizedString(@"Advanced", nil) descriptionText:_exerciseInstruction.advancedQuantity];
    self.quantityLabelBeginner.attributedText = [self attributedStringForLabelText:NSLocalizedString(@"Beginner", nil) descriptionText:_exerciseInstruction.beginnerQuantity];
    self.quantityLabelIntermediate.attributedText = [self attributedStringForLabelText:NSLocalizedString(@"Intermediate", nil) descriptionText:_exerciseInstruction.intermediateQuantity];
    
    self.titleLabel.text = [_exerciseInstruction.exercise.title uppercaseString];
    
    if (exerciseInstruction.exercise.steps && ([exerciseInstruction.exercise.steps count] > 0)) {
        self.accessoryImageView.image = [UIImage tintableImageNamed:@"forwardIcon"];
        self.selectedBackgroundView.backgroundColor = [RJStyleManager sharedInstance].tintLightGrayColor;
    } else {
        self.accessoryImageView.image = nil;
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - Private Class Methods

- (NSAttributedString *)attributedStringForLabelText:(NSString *)labelText descriptionText:(NSString *)descriptionText {
    NSAttributedString *attributedString = nil;
    if (descriptionText) {
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        NSDictionary *boldAttributes = @{
                                         NSFontAttributeName : styleManager.verySmallBoldFont,
                                         NSForegroundColorAttributeName : styleManager.themeTextColor
                                         };
        NSDictionary *regularAttributes = @{
                                            NSFontAttributeName : styleManager.verySmallFont,
                                            NSForegroundColorAttributeName : styleManager.themeTextColor
                                            };
        
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        [mutableAttributedString appendAttributedString:
         [[NSAttributedString alloc] initWithString:labelText attributes:boldAttributes]];
        [mutableAttributedString appendAttributedString:
         [[NSAttributedString alloc] initWithString:@": " attributes:boldAttributes]];
        [mutableAttributedString appendAttributedString:
         [[NSAttributedString alloc] initWithString:descriptionText attributes:regularAttributes]];
        
        attributedString = mutableAttributedString;
    }
    return attributedString;
}

#pragma mark - Private Instance Methods

- (void)leftSideAccessoryButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(exerciseInstructionCellDidSelectLeftSideAccessoryButton:)]) {
        [self.delegate exerciseInstructionCellDidSelectLeftSideAccessoryButton:self];
    }
}

#pragma mark - Public Class Methods

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Public Instance Methods - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] init];
        
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        
        _accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _accessoryImageView.tintColor = styleManager.themeTextColor;
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_accessoryImageView];
        
        _leftSideAccessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftSideAccessoryButton addTarget:self action:@selector(leftSideAccessoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_leftSideAccessoryButton];
        
        UIEdgeInsets labelInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
        
        _quantityLabelAllLevels = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _quantityLabelAllLevels.insets = labelInsets;
        _quantityLabelAllLevels.textColor = styleManager.themeTextColor;
        _quantityLabelAllLevels.font = styleManager.verySmallFont;
        [self.contentView addSubview:_quantityLabelAllLevels];
        
        _quantityLabelBeginner = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _quantityLabelBeginner.insets = labelInsets;
        [self.contentView addSubview:_quantityLabelBeginner];
        
        _quantityLabelIntermediate = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _quantityLabelIntermediate.insets = labelInsets;
        [self.contentView addSubview:_quantityLabelIntermediate];
        
        _quantityLabelAdvanced = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _quantityLabelAdvanced.insets = labelInsets;
        [self.contentView addSubview:_quantityLabelAdvanced];
        
        _spacer = [[UIView alloc] initWithFrame:CGRectZero];
        _spacer.backgroundColor = styleManager.themeTextColor;
        [self.contentView addSubview:_spacer];
        
        _titleLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = styleManager.themeTextColor;
        _titleLabel.insets = labelInsets;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

#pragma mark - Public Instance Methods - Layout

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.minimized) {
        return CGSizeMake(size.width, kTitleElementsHeight + kSpacerHeight);
    } else {
        CGFloat height = 0.0f;
        height += kMarginTop;
        height += [self.titleLabel sizeThatFits:size].height;
        height += [self.quantityLabelAllLevels sizeThatFits:size].height;
        height += [self.quantityLabelAdvanced sizeThatFits:size].height;
        height += [self.quantityLabelBeginner sizeThatFits:size].height;
        height += [self.quantityLabelIntermediate sizeThatFits:size].height;
        height += kMarginBottom;
        height += kSpacerHeight;
        return CGSizeMake(size.width, height + kSpacerHeight);
    }
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        UIView *accessoryImageView = self.accessoryImageView;
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *leftSideAccessoryButton = self.leftSideAccessoryButton;
        leftSideAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *quantityLabelAllLevels = self.quantityLabelAllLevels;
        quantityLabelAllLevels.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *quantityLabelAdvanced = self.quantityLabelAdvanced;
        quantityLabelAdvanced.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *quantityLabelBeginner = self.quantityLabelBeginner;
        quantityLabelBeginner.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *quantityLabelIntermediate = self.quantityLabelIntermediate;
        quantityLabelIntermediate.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *spacer = self.spacer;
        spacer.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView *titleLabel = self.titleLabel;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(accessoryImageView, leftSideAccessoryButton, quantityLabelAdvanced, quantityLabelAllLevels, quantityLabelBeginner, quantityLabelIntermediate, spacer, titleLabel);
        NSDictionary *metrics = @{
                                  @"titleElementsHeight" : @(kTitleElementsHeight),
                                  @"buttonElementsWidth" : @(kButtonElementsWidth),
                                  @"spacerHeight" : @(kSpacerHeight),
                                  @"marginTop" : @(kMarginTop),
                                  @"marginBottom" : @(kMarginBottom)
                                  };
        
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftSideAccessoryButton]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[accessoryImageView]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-marginTop-[titleLabel][quantityLabelAllLevels][quantityLabelBeginner][quantityLabelIntermediate][quantityLabelAdvanced]-marginBottom-[spacer(spacerHeight)]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftSideAccessoryButton(buttonElementsWidth)][titleLabel][accessoryImageView(7)]-10-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spacer]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:quantityLabelAdvanced attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:quantityLabelAllLevels attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:quantityLabelBeginner attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:quantityLabelIntermediate attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
        
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
