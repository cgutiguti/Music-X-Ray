//
//  SearchViewController.m
//  Bounce
//
//  Created by Carmen Gutierrez on 7/13/20.
//  Copyright © 2020 Carmen Gutierrez. All rights reserved.
//

//view controllers
#import "SearchViewController.h"
#import "TrackDetailsViewController.h"
#import "ArtistDetailsViewController.h"
#import "AffinitiesViewController.h"
//model cells
#import "TrackCell.h"
#import "ArtistCell.h"
//outside functions
#import "AppDelegate.h"
#import "SpotifyManager.h"
#import "UIImageView+AFNetworking.h"
//models
#import "Track.h"
#import "Artist.h"




@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
//storyboard outlets
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *typeControl;
//data

@property NSArray *resultsArray;
//personal booleans for state of search
@property BOOL completedSearchForTrack;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.searchBar.showsSearchResultsButton = NO;
    [self.typeControl addTarget:self action:@selector(doSearchUsingManager) forControlEvents:UIControlEventValueChanged];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Do the search...
    if (self.searchBar.searchTextField.text.length != 0) {
        NSLog([@"Authorization Token: " stringByAppendingString:self.accessToken]);
        // fetch data with predicate from spotify api
        //[self doSearchUsingHTTPDefault];
        [self doSearchUsingManager];
    }
    [searchBar resignFirstResponder];
}

- (void)doSearchUsingManager {
    if ([self.typeControl selectedSegmentIndex] == 0) {//search for song
        self.completedSearchForTrack = YES;
        [[SpotifyManager shared] searchForSong:[self.searchBar.searchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"] accessToken:self.accessToken completion:^(NSDictionary * _Nonnull array, NSError * _Nonnull error) {
                self.resultsArray = array[@"tracks"][@"items"];
                [self.tableView reloadData];
            }];
    } else { // search for artist
        self.completedSearchForTrack = NO;
        [[SpotifyManager shared] searchForArtist:[self.searchBar.searchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"] accessToken:self.accessToken completion:^(NSDictionary * _Nonnull array, NSError * _Nonnull error) {
            self.resultsArray = array[@"artists"][@"items"];
             [self.tableView reloadData];
        }];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  
    if (self.completedSearchForTrack) {//search for song
        TrackCell *cell = [tableView dequeueReusableCellWithIdentifier: @"TrackCell"];
        Track *track = [[Track alloc] initWithDictionary:self.resultsArray[indexPath.row]];
        NSString *artistsList = @"";
        //loop over list of artists of track, then append them together using commas
        for (NSDictionary *artist in track.artists) {
            if(artistsList.length == 0) { //if this is the first artist we are adding, don't add a , before its name
                artistsList = [artistsList stringByAppendingFormat:@"%@", artist[@"name"]];
            } else {
                artistsList = [artistsList stringByAppendingFormat:@", %@", artist[@"name"]];
            }
        }
        cell.trackArtistLabel.text = artistsList;
        cell.trackTitleLabel.text = track.name;
        cell.track = track;
        NSURL *url = [NSURL URLWithString:track.album.image.url];
        [cell.albumArtView setImageWithURL:url];
        cell.albumArtView.layer.cornerRadius = 5;
        cell.albumArtView.clipsToBounds = YES;
        return cell;
    } else { //search for artist
        ArtistCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ArtistCell"];
        Artist *artist = [[Artist alloc] initWithDictionary:self.resultsArray[indexPath.row]];
        cell.artist = artist;
        cell.artistNameLabel.text = artist.name;
        NSURL *url = [NSURL URLWithString:artist.image.url];
        [cell.artistImageView setImageWithURL:url];
        cell.artistImageView.layer.cornerRadius =  cell.artistImageView.frame.size.width/2;
        cell.artistImageView.clipsToBounds = YES;
        return cell;
    }
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (self.completedSearchForTrack) { //did complete search for a track
        TrackCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Track *track = [[Track alloc] initWithDictionary:self.resultsArray[indexPath.row]];
        TrackDetailsViewController *detailsVC = [segue destinationViewController];
        detailsVC.accessToken = self.accessToken;
        detailsVC.track = track;
    } else {//did complete search for an artist
        ArtistCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Artist *artist = [[Artist alloc] initWithDictionary:self.resultsArray[indexPath.row]];
        ArtistDetailsViewController *detailsVC = [segue destinationViewController];
        detailsVC.accessToken = self.accessToken;
        detailsVC.artist = artist;
    }
}
@end
