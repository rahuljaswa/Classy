//
//  RJClassCommentsViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 6/11/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAuthenticationViewController.h"
#import "RJClassCommentsViewController.h"
#import "RJParseComment.h"
#import "RJParseLike.h"
#import "RJParseUser.h"
#import "RJStyleManager.h"
#import <ChatViewControllers/RJWriteChatView.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

static NSString *const kClassCommentsViewControllerCellID = @"ClassCommentsViewControllerCellID";


@interface RJClassCommentsViewController () <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic, strong) NSArray *commentsAndLikes;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end


@implementation RJClassCommentsViewController

#pragma mark - Private Protocols - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = nil;
    if ([RJParseUser currentUser]) {
        text = NSLocalizedString(@"Share your tips and comments about this workout", nil);
    } else {
        text = NSLocalizedString(@"Please login to write a comment", nil);
    }
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    NSDictionary *attributes = [RJStyleManager attributesWithFont:styleManager.mediumBoldFont textColor:styleManager.themeTextColor textAlignment:NSTextAlignmentCenter];
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    return nil;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = nil;
    if ([RJParseUser currentUser]) {
        text = NSLocalizedString(@"Write a Comment", nil);
    } else {
        text = NSLocalizedString(@"Login Now", nil);
    }
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    NSDictionary *baseAttributes = nil;
    if (state == UIControlStateHighlighted) {
        baseAttributes = [RJStyleManager attributesWithFont:styleManager.mediumFont textColor:styleManager.themeTextColor textAlignment:NSTextAlignmentCenter];
    } else {
        baseAttributes = [RJStyleManager attributesWithFont:styleManager.mediumFont textColor:styleManager.tintBlueColor textAlignment:NSTextAlignmentCenter];
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:baseAttributes];
    [attributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIColor clearColor];
}

- (CGPoint)offsetForEmptyDataSet:(UIScrollView *)scrollView {
    return CGPointMake(0, -50.0f);
}

#pragma mark - Private Protocols - DZNEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    if ([RJParseUser currentUser]) {
        [self.writeChatView becomeFirstResponder];
    } else {
        [self presentAuthentication];
    }
}

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentsAndLikes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kClassCommentsViewControllerCellID forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Private Protocols - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static UITableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [sizingCell.textLabel sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
}

#pragma mark - Private Instance Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *creatorText = nil;
    NSString *commentText = nil;
    
    id commentOrLike = self.commentsAndLikes[indexPath.row];
    if ([commentOrLike isKindOfClass:[RJParseComment class]]) {
        RJParseComment *comment = (RJParseComment *)commentOrLike;
        creatorText = comment.creator.name;
        commentText = comment.text;
    } else {
        RJParseLike *like = (RJParseLike *)commentOrLike;
        creatorText = like.creator.name;
        commentText = NSLocalizedString(@"Like!", nil);
    }
    
    RJStyleManager *styleManager = [RJStyleManager sharedInstance];
    NSDictionary *boldSmallAttributes = [RJStyleManager attributesWithFont:styleManager.verySmallBoldFont textColor:styleManager.themeTextColor textAlignment:NSTextAlignmentLeft];
    NSDictionary *smallAttributes = [RJStyleManager attributesWithFont:styleManager.verySmallFont textColor:styleManager.themeTextColor textAlignment:NSTextAlignmentLeft];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    if (!creatorText) {
        creatorText = NSLocalizedString(@"Anonymous", nil);
    }
    [text appendAttributedString:
     [[NSAttributedString alloc] initWithString:creatorText attributes:boldSmallAttributes]];
    [text appendAttributedString:
     [[NSAttributedString alloc] initWithString:@" "]];
    [text appendAttributedString:
     [[NSAttributedString alloc] initWithString:commentText attributes:smallAttributes]];
    cell.textLabel.attributedText = text;
}

- (void)presentAuthentication {
    [[RJAuthenticationViewController sharedInstance] startWithPresentingViewController:self completion:^(RJParseUser *user) {
        [self updateWriteChatView];
        [self.tableView reloadData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)sendButtonPressed:(UIButton *)button {
    [self.classCommentsDelegate classCommentsViewControllerDidPressSendButton:self];
}

- (void)writeChatViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self presentAuthentication];
}

- (void)updateWriteChatView {
    BOOL enabled;
    if ([RJParseUser currentUser]) {
        enabled = YES;
        [self.writeChatView removeGestureRecognizer:self.tapGestureRecognizer];
    } else {
        enabled = NO;
        [self.writeChatView addGestureRecognizer:self.tapGestureRecognizer];
    }
    
    self.writeChatView.commentView.userInteractionEnabled = enabled;
    self.writeChatView.sendButton.userInteractionEnabled = enabled;
}

#pragma mark - Public Instance Methods

- (void)dealloc {
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
}

- (void)setComments:(NSArray *)comments likes:(NSArray *)likes {
    NSMutableArray *commentsAndLikes = [[NSMutableArray alloc] init];
    if (comments) {
        [commentsAndLikes addObjectsFromArray:comments];
    }
    if (likes) {
        [commentsAndLikes addObjectsFromArray:likes];
    }
    [commentsAndLikes sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    self.commentsAndLikes = commentsAndLikes;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeChatViewTapped:)];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kClassCommentsViewControllerCellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *writeChatViewTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0f, CGRectGetWidth(self.writeChatView.bounds), 1.0f)];
    writeChatViewTopBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    writeChatViewTopBorder.backgroundColor = [RJStyleManager sharedInstance].themeTextColor;
    [self.writeChatView addSubview:writeChatViewTopBorder];
    
    [self.writeChatView.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self updateWriteChatView];
}

@end
