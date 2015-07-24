//
//  RJTrackSelectorViewController.m
//  FitnessClasses
//
//  Created by Rahul Jaswa on 7/19/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "NSString+Temporal.h"
#import "RJLoadingTableViewCell.h"
#import "RJStyleManager.h"
#import "RJSoundCloudAPIClient.h"
#import "RJSoundCloudTrack.h"
#import "RJTrackSelectorViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
@import AVFoundation.AVPlayer;
@import AVFoundation.AVPlayerItem;

static NSString *const kRJTrackSelectorViewControllerSearchResultsCellID = @"RJTrackSelectorViewControllerSearchResultsCellID";
static NSString *const kRJTrackSelectorControllerLoadingCell = @"RJLoadingCellID";


@interface RJTrackSelectorViewController () <NSURLConnectionDelegate, RJSingleSelectionViewControllerDataSource>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSIndexPath *checkingIndexPath;

@end


@implementation RJTrackSelectorViewController

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController titleForObject:(NSObject *)object {
    RJSoundCloudTrack *track = (RJSoundCloudTrack *)object;
    return track.title;
}

- (NSString *)singleSelectionViewController:(RJSinglePFObjectSelectionViewController *)viewController subtitleForObject:(NSObject *)object {
    RJSoundCloudTrack *track = (RJSoundCloudTrack *)object;
    return [NSString stringWithFormat:@"%@ - %@", [NSString hhmmaaForTotalSeconds:track.length], track.artist];
}

#pragma mark - Private Protocols - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [[RJSoundCloudAPIClient sharedAPIClient] getTracksMatchingKeyword:searchBar.text completion:^(NSArray *tracks) {
        self.objects = tracks;
        [self.tableView reloadData];
    }];
}

#pragma mark - Public Protocols - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"playIcon"];
    if ([cell.imageView.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [cell.imageView addGestureRecognizer:tapRecognizer];
    }
    cell.imageView.userInteractionEnabled = YES;
    cell.imageView.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Verifying track...", nil) maskType:SVProgressHUDMaskTypeClear];
    
    NSString *trackSteamURL = [self.objects[indexPath.item] streamURL];
    NSURL *authenticatedTrackStreamURL = [[RJSoundCloudAPIClient sharedAPIClient] authenticatingStreamURLWithStreamURL:trackSteamURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authenticatedTrackStreamURL];
    [request setHTTPMethod:@"HEAD"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    self.checkingIndexPath = indexPath;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - Private Protocols - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 200) {
        [super tableView:self.tableView didSelectRowAtIndexPath:self.checkingIndexPath];
        [SVProgressHUD dismiss];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Track is broken", nil)];
    }
    self.checkingIndexPath = nil;
}

#pragma mark - Private Instance Methods

- (void)clearClass {
    [self.player removeObserver:self forKeyPath:@"status"];
    self.player = nil;
}

- (void)tapRecognized:(UITapGestureRecognizer *)tapRecognizer {
    [self clearClass];
    
    RJSoundCloudTrack *track = (RJSoundCloudTrack *)[self.objects objectAtIndex:tapRecognizer.view.tag];
    NSURL *streamURL = [[RJSoundCloudAPIClient sharedAPIClient] authenticatingStreamURLWithStreamURL:track.streamURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:streamURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Public Instance Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == self.player) && [keyPath isEqualToString:@"status"] && (self.player.status == AVPlayerStatusReadyToPlay)) {
        [self.player play];
    }
}

- (void)dealloc {
    [self clearClass];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataSource = self;
        self.incrementalSearchEnabled = NO;
    }
    return self;
}

@end
