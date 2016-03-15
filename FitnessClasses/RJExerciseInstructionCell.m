//
//  RJExerciseInstructionCell.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/13/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJClassImageCacheEntity.h"
#import "RJExerciseInstructionCell.h"
#import "RJParseExercise.h"
#import "RJParseExerciseInstruction.h"
#import "RJStyleManager.h"
#import "UIImageView+FastImageCache.h"
#import <UIToolkitIOS/RJInsetLabel.h>
#import <UIToolkitIOS/UIImage+RJAdditions.h>

static const CGFloat kMarginTop = 10.0f;
static const CGFloat kMarginBottom = 10.0f;
static const CGFloat kTitleElementsHeight = 44.0f;
static const CGFloat kAccessoryImageWidth = 7.0f;
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
    
    if (!self.quantityLabelAllLevels.text) {
        self.quantityLabelAdvanced.attributedText = [self attributedStringForLabelText:NSLocalizedString(@"Advanced", nil) descriptionText:_exerciseInstruction.advancedQuantity];
        self.quantityLabelBeginner.attributedText = [self attributedStringForLabelText:NSLocalizedString(@"Beginner", nil) descriptionText:_exerciseInstruction.beginnerQuantity];
        self.quantityLabelIntermediate.attributedText = [self attributedStringForLabelText:NSLocalizedString(@"Intermediate", nil) descriptionText:_exerciseInstruction.intermediateQuantity];
    } else {
        self.quantityLabelAdvanced.attributedText = nil;
        self.quantityLabelBeginner.attributedText = nil;
        self.quantityLabelIntermediate.attributedText = nil;
    }
    
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

- (void)updatePreferredMaxLayoutWidthForInsetLabel:(RJInsetLabel *)insetLabel {
    CGFloat labelWidth = (CGRectGetWidth(self.bounds) - kButtonElementsWidth - kAccessoryImageWidth - insetLabel.insets.left - insetLabel.insets.right);
    if (insetLabel.preferredMaxLayoutWidth != labelWidth) {
        insetLabel.preferredMaxLayoutWidth = labelWidth;
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
        _quantityLabelAllLevels.lineBreakMode = NSLineBreakByWordWrapping;
        _quantityLabelAllLevels.numberOfLines = 0;
        _quantityLabelAllLevels.insets = labelInsets;
        _quantityLabelAllLevels.textColor = styleManager.themeTextColor;
        _quantityLabelAllLevels.font = styleManager.verySmallFont;
        [self.contentView addSubview:_quantityLabelAllLevels];
        
        _quantityLabelBeginner = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _quantityLabelBeginner.lineBreakMode = NSLineBreakByWordWrapping;
        _quantityLabelBeginner.numberOfLines = 0;
        _quantityLabelBeginner.insets = labelInsets;
        [self.contentView addSubview:_quantityLabelBeginner];
        
        _quantityLabelIntermediate = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _quantityLabelIntermediate.lineBreakMode = NSLineBreakByWordWrapping;
        _quantityLabelIntermediate.numberOfLines = 0;
        _quantityLabelIntermediate.insets = labelInsets;
        [self.contentView addSubview:_quantityLabelIntermediate];
        
        _quantityLabelAdvanced = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _quantityLabelAdvanced.lineBreakMode = NSLineBreakByWordWrapping;
        _quantityLabelAdvanced.numberOfLines = 0;
        _quantityLabelAdvanced.insets = labelInsets;
        [self.contentView addSubview:_quantityLabelAdvanced];
        
        _spacer = [[UIView alloc] initWithFrame:CGRectZero];
        _spacer.backgroundColor = styleManager.themeTextColor;
        [self.contentView addSubview:_spacer];
        
        _titleLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = styleManager.themeTextColor;
        _titleLabel.insets = labelInsets;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

#pragma mark - Public Instance Methods - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updatePreferredMaxLayoutWidthForInsetLabel:self.titleLabel];
    [self updatePreferredMaxLayoutWidthForInsetLabel:self.quantityLabelAllLevels];
    [self updatePreferredMaxLayoutWidthForInsetLabel:self.quantityLabelAdvanced];
    [self updatePreferredMaxLayoutWidthForInsetLabel:self.quantityLabelBeginner];
    [self updatePreferredMaxLayoutWidthForInsetLabel:self.quantityLabelIntermediate];
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.minimized) {
        return CGSizeMake(size.width, kTitleElementsHeight + kSpacerHeight);
    } else {
        CGFloat labelMaxWidth = (size.width - kButtonElementsWidth - kAccessoryImageWidth);
        CGSize labelMaxSize = CGSizeMake(labelMaxWidth, size.height);
        CGFloat height = 0.0f;
        height += kMarginTop;
        height += [self.titleLabel sizeThatFits:labelMaxSize].height;
        height += [self.quantityLabelAllLevels sizeThatFits:labelMaxSize].height;
        height += [self.quantityLabelAdvanced sizeThatFits:labelMaxSize].height;
        height += [self.quantityLabelBeginner sizeThatFits:labelMaxSize].height;
        height += [self.quantityLabelIntermediate sizeThatFits:labelMaxSize].height;
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
                                  @"accessoryImageWidth" : @(kAccessoryImageWidth),
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
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftSideAccessoryButton(buttonElementsWidth)][titleLabel][accessoryImageView(accessoryImageWidth)]-10-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spacer]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftSideAccessoryButton][quantityLabelAdvanced][accessoryImageView]" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftSideAccessoryButton][quantityLabelAllLevels][accessoryImageView]" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftSideAccessoryButton][quantityLabelBeginner][accessoryImageView]" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftSideAccessoryButton][quantityLabelIntermediate][accessoryImageView]" options:0 metrics:metrics views:views]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

@end
