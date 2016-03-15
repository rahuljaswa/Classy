//
//  UINavigationItem+RJAdditions.m
//  Community
//

#import "RJStyleManager.h"
#import "UINavigationItem+RJAdditions.h"

@implementation UINavigationItem (RJAdditions)

- (UIBarButtonItem *)backBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    item.tintColor = [RJStyleManager sharedInstance].accentColor;
    return item;
}

@end
