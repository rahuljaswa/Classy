//
//  RJLabelCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJInsetLabel.h"
#import "RJLabelCell.h"
#import <SZTextView/SZTextView.h>

static const CGFloat kAccessoryViewWidth = 7.0f;
static const CGFloat kMarginRight = 10.0f;


@interface RJLabelCell ()

@property (nonatomic, assign, getter = hasSetupStaticConstraints) BOOL setupStaticConstraints;

@end


@implementation RJLabelCell

- (void)setStyle:(RJLabelCellStyle)style {
    _style = style;
    switch (style) {
        case kRJLabelCellStyleTextField:
            self.textField.hidden = NO;
            self.textLabel.hidden = YES;
            self.textView.hidden = YES;
            break;
        case kRJLabelCellStyleTextLabel:
            self.textField.hidden = YES;
            self.textLabel.hidden = NO;
            self.textView.hidden = YES;
            break;
        case kRJLabelCellStyleTextView:
            self.textField.hidden = YES;
            self.textLabel.hidden = YES;
            self.textView.hidden = NO;
            break;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
        _textField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        _textField.rightViewMode = UITextFieldViewModeAlways;
        [self.contentView addSubview:_textField];
        
        _textView = [[SZTextView alloc] initWithFrame:self.contentView.bounds];
        _textView.textContainerInset = UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f);
        _textView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self.contentView addSubview:_textView];
        
        _textLabel = [[RJInsetLabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textLabel];
        
        _accessoryView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _accessoryView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_accessoryView];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_topBorder];
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomBorder];
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.style = kRJLabelCellStyleTextLabel;
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    if (!self.hasSetupStaticConstraints) {
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _accessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        _topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel, _accessoryView, _topBorder, _bottomBorder);
        NSDictionary *metrics = @{
                                  @"accessoryViewWidth" : @(kAccessoryViewWidth),
                                  @"marginRight" : @(kMarginRight),
                                  };
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textLabel]|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_accessoryView(accessoryViewWidth)]-marginRight-|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBorder]|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomBorder]|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel]|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_accessoryView]|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBorder(==0.5)]"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomBorder(==0.5)]|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        
        self.setupStaticConstraints = YES;
    }
    
    [super updateConstraints];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = CGSizeMake(size.width, 0.0f);
    switch (self.style) {
        case kRJLabelCellStyleTextField:
            sizeThatFits.height += [self.textField sizeThatFits:CGSizeMake(sizeThatFits.width, CGFLOAT_MAX)].height;
            break;
        case kRJLabelCellStyleTextLabel:
            sizeThatFits.width -= kAccessoryViewWidth;
            sizeThatFits.height += [self.textLabel sizeThatFits:CGSizeMake(sizeThatFits.width, CGFLOAT_MAX)].height;
            break;
        case kRJLabelCellStyleTextView:
            sizeThatFits.height += [self.textView sizeThatFits:CGSizeMake(sizeThatFits.width, CGFLOAT_MAX)].height;
            break;
    }
    return sizeThatFits;
}

@end
