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
@import AVFoundation.AVPlayer;
@import AVFoundation.AVPlayerItem;

static NSString *const kRJTrackSelectorViewControllerSearchResultsCellID = @"RJTrackSelectorViewControllerSearchResultsCellID";
static NSString *const kRJTrackSelectorControllerLoadingCell = @"RJLoadingCellID";


@interface RJTrackSelectorViewController () <UISearchBarDelegate, RJSingleSelectionViewControllerDataSource>

@property (nonatomic, strong, readonly) UISearchBar *searchBar;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, assign, getter=isSearching) BOOL searching;

@end


@implementation RJTrackSelectorViewController

#pragma mark - Private Instance Methods - Search Results Updating

- (void)updateSearchResultsForString:(NSString *)text {
    [self.tableView reloadData];
}

#pragma mark - Private Protocols - RJSingleSelectionViewControllerDataSource

- (NSString *)singleSelectionViewController:(RJSingleSelectionViewController *)viewController titleForObject:(NSObject *)object {
    RJSoundCloudTrack *track = (RJSoundCloudTrack *)object;
    return track.title;
}

- (NSString *)singleSelectionViewController:(RJSingleSelectionViewController *)viewController subtitleForObject:(NSObject *)object {
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
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSearchResultsForString:searchText];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.searching = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    self.searching = NO;
    return YES;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
        
        RJStyleManager *styleManager = [RJStyleManager sharedInstance];
        
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.tintColor = styleManager.tintBlueColor;
        _searchBar.barStyle = UIBarStyleBlack;
        _searchBar.showsCancelButton = NO;
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    if (!self.isSearching) {
        [super viewDidLayoutSubviews];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchBar;
}

@end
