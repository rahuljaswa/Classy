//
//  RJTextFieldTableViewCell.m
//  InteriorDesign
//
//  Created by Rahul Jaswa on 8/27/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJTextFieldTableViewCell.h"


@implementation RJTextFieldTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
        _textField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 0.0f)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        [self.contentView addSubview:_textField];
    }
    return self;
}

@end
