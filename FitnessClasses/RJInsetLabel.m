//
//  RJInsetLabel.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/2/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJInsetLabel.h"


@implementation RJInsetLabel

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

- (CGSize)intrinsicContentSize {
    CGSize computedSize = [super intrinsicContentSize];
    computedSize.width += (self.insets.left + self.insets.right);
    computedSize.height += (self.insets.top + self.insets.bottom);
    return computedSize;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize boundingSize = CGSizeMake((size.width - self.insets.left - self.insets.right), size.height);
    CGSize computedSize = [super sizeThatFits:boundingSize];
    computedSize.height += (self.insets.top + self.insets.bottom);
    computedSize.width += (self.insets.left + self.insets.right);
    return computedSize;
}

@end
