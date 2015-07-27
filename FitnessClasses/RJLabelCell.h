//
//  RJLabelCell.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/14/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RJLabelCellStyle) {
    kRJLabelCellStyleTextLabel,
    kRJLabelCellStyleTextField,
    kRJLabelCellStyleTextView
};


@class RJInsetLabel;
@class SZTextView;

@interface RJLabelCell : UICollectionViewCell

@property (nonatomic, assign) RJLabelCellStyle style;

@property (nonatomic, strong, readonly) UIImageView *accessoryView;
@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong, readonly) RJInsetLabel *textLabel;
@property (nonatomic, strong, readonly) SZTextView *textView;

@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIView *topBorder;

@end
