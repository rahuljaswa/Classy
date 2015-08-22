//
//  RJClassDetailsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/12/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJClassCommentsViewController.h"
#import "RJClassDetailsViewController.h"
#import "RJCreateEditChoreographedClassViewController.h"
#import "RJCreateEditSelfPacedClassViewController.h"
#import "RJParseCategory.h"
#import "RJParseClass.h"
#import "RJParseUser.h"
#import "RJParseUtils.h"
#import "RJStackedTitleView.h"
#import "RJStyleManager.h"
#import "UIBarButtonItem+RJAdditions.h"
#import "UIImage+RJAdditions.h"
#import <ChatViewControllers/RJWriteChatView.h>


@interface RJClassDetailsViewController () <RJClassCommentsViewControllerDelegate>

@property (nonatomic, strong, readonly) RJClassCommentsViewController *commentsViewController;
@property (nonatomic, strong, readonly) RJStackedTitleView *titleView;

@end


@implementation RJClassDetailsViewController

@synthesize commentsViewController = _commentsViewController;

#pragma mark - Public Properties

- (void)setKlass:(RJParseClass *)klass {
    _klass = klass;
    [self updateUI];
}

- (void)setShowsPlayButton:(BOOL)showsPlayButton {
    _showsPlayButton = showsPlayButton;
    if (_showsPlayButton) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem playBarButtonItemWithTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside tintColor:[RJStyleManager sharedInstance].accentColor];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Private Properties

- (RJClassCommentsViewController *)commentsViewController {
    if (!_commentsViewController) {
        _commentsViewController = [[RJClassCommentsViewController alloc] initWithStyle:UITableViewStylePlain];
        _commentsViewController.classCommentsDelegate = self;
    }
    return _commentsViewController;
}

#pragma mark - Private Protocols - RJClassCommentsViewControllerDelegate

- (void)classCommentsViewControllerDidPressSendButton:(RJClassCommentsViewController *)classCommentsViewController {
    NSString *text = classCommentsViewController.writeChatView.commentView.text;
    if ([text length] > 0) {
        [classCommentsViewController.writeChatView reset];
        [RJParseUtils insertCommentForClass:self.klass text:text completion:^(BOOL success) {
            if (success) {
                [RJParseUtils fetchClassWithId:self.klass.objectId completion:^(RJParseClass *klass) {
                    if (klass) {
                        self.klass = klass;
                    }
                }];
            }
        }];
    }
}

#pragma mark - Private Instance Methods

- (void)playButtonPressed:(UIButton *)button {
    [self.delegate classDetailsViewControllerDidPressPlayButton:self];
}

- (void)updateUI {
    self.titleView.textLabel.text = [self.klass.name uppercaseString];
    self.titleView.detailTextLabel.text = self.klass.category.name;
    [self.commentsViewController setComments:self.klass.comments likes:self.klass.likes];
}

#pragma mark - Private Instance Methods - Handlers

- (void)editButtonPressed:(UIButton *)button {
    RJParseClassType classType = [self.klass.classType integerValue];
    switch (classType) {
        case kRJParseClassTypeNone:
            break;
        case kRJParseClassTypeChoreographed: {
            RJCreateEditChoreographedClassViewController *editViewController = [[RJCreateEditChoreographedClassViewController alloc] init];
            editViewController.klass = self.klass;
            [[self navigationController] pushViewController:editViewController animated:YES];
            break;
        }
        case kRJParseClassTypeSelfPaced: {
            RJCreateEditSelfPacedClassViewController *editViewController = [[RJCreateEditSelfPacedClassViewController alloc] init];
            editViewController.klass = self.klass;
            [[self navigationController] pushViewController:editViewController animated:YES];
            break;
        }
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _titleView = [[RJStackedTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.commentsViewController willMoveToParentViewController:self];
    [self addChildViewController:self.commentsViewController];
    self.commentsViewController.view.frame = self.view.bounds;
    self.commentsViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:self.commentsViewController.view];
    [self.commentsViewController didMoveToParentViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [RJStyleManager sharedInstance].themeBackgroundColor;
    
    self.navigationItem.titleView = self.titleView;
    if ([[RJParseUser currentUser] admin]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage tintableImageNamed:@"settingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:item];
    }
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    
    self.titleView.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.detailTextLabel.textColor = styleManager.themeTextColor;
    self.titleView.detailTextLabel.font = styleManager.verySmallBoldFont;
    
    self.titleView.textLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView.textLabel.textColor = styleManager.titleColor;
    self.titleView.textLabel.font = styleManager.navigationBarFont;
    
    self.commentsViewController.view.backgroundColor = [UIColor clearColor];
    self.commentsViewController.writeChatView.backgroundColor = styleManager.themeBackgroundColor;
    self.commentsViewController.writeChatView.commentView.backgroundColor = [UIColor clearColor];
    self.commentsViewController.writeChatView.commentView.textColor = styleManager.themeTextColor;
    self.commentsViewController.writeChatView.commentView.tintColor = styleManager.themeTextColor;
    self.commentsViewController.writeChatView.commentView.layer.borderColor = styleManager.themeTextColor.CGColor;
    self.commentsViewController.writeChatView.commentView.layer.borderWidth = 1.0f;
    [self.commentsViewController.writeChatView.sendButton setTitleColor:styleManager.themeTextColor forState:UIControlStateNormal];
    self.commentsViewController.writeChatView.sendButton.titleLabel.font = styleManager.verySmallBoldFont;    
}

@end
