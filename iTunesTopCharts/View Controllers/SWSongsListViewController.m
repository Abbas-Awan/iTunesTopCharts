//
//  SWSongsListViewController.m
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import "SWSongsListViewController.h"
#import "SWWebServices.h"
#import "SWAppDelegate.h"
#import "SWSongInfoCell.h"
#import "SWImageViewController.h"

#import "Song+Custom.h"

#pragma mark - Private Interface

@interface SWSongsListViewController () <SWWebServicesDelegate, SWSongInfoCellDelegate>

@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) NSUInteger songsCount;

- (void)setup;
- (void)reloadTopSongs;
- (void)processImages;
- (void)updateProgressView;

@end

#pragma mark - Implementation

@implementation SWSongsListViewController

@synthesize songsCount = _songsCount;
@synthesize progressView = _progressView;
@synthesize progressLabel = _progressLabel;
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSManagedObjectContext *moc = [AppDelegate managedObjectContext];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Core Data Fetch Error: %@", [error localizedDescription]);
    }
    
    return _fetchedResultsController;
}

#pragma mark - Init & Dealloc methods

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.songsCount = -1;
    }
    return self;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SongCell";
    
    SWSongInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[SWSongInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    Song *songAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.song = songAtIndexPath;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Song *songAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (songAtIndexPath.image != nil) {
        SWImageViewController *viewController = [[SWImageViewController alloc] init];
        viewController.image = [UIImage imageWithData:songAtIndexPath.image];
        
        CATransition* transition = [CATransition animation];
        transition.duration = 1.0;
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        
        [self.navigationController pushViewController:viewController animated:NO];
    }
}

#pragma mark - SWSongInfoCellDelegate methods

- (void)swSongInfoCellImageViewTapped:(SWSongInfoCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Song *songAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self openiTunesForSong:songAtIndexPath.link];
}

#pragma mark - SWWebServicesDelegate methods

- (void)swWebServices:(SWWebServices *)request failedWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alert show];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)swWebServices:(SWWebServices *)request finishedWithList:(NSArray *)songsList {
    
    if ([songsList count] > 0) {
        
        // Delete all existing songs
        [Song deleteAllSongsInManagedObjectContext:[AppDelegate managedObjectContext]];
        
        for (NSDictionary *song in songsList) {
            Song *aSong = [Song newSongFromInfo:song inManagedObjectContext:[AppDelegate managedObjectContext]];
        }
        
        NSError *error = nil;
        
        if (![[AppDelegate managedObjectContext] save:&error]) {
            NSLog(@"Core Data Save Error: %@", [error localizedDescription]);
            
        } else {
            self.fetchedResultsController = nil;
            [self.tableView reloadData];
        }
        
        // Asyncronously process images
        [self processImages];
    }
}

#pragma mark - Private methods

- (void)setup {
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTopSongs)];
    
    self.navigationItem.rightBarButtonItem = reloadButton;
    
    if ([self.fetchedResultsController.fetchedObjects count] <= 0) {
        [self reloadTopSongs];
    }
}

- (void)reloadTopSongs {
    
    // Add top view
    if (self.progressView == nil) {
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 21)];
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60 , 21)];
        self.progressLabel.center = self.progressView.center;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.frame = CGRectMake(self.progressView.frame.size.width - self.activityIndicator.frame.size.width,
                                                  self.progressView.frame.size.height - self.activityIndicator.frame.size.height,
                                                  self.activityIndicator.frame.size.width,
                                                  self.activityIndicator.frame.size.height);
        self.progressLabel.center = self.progressView.center;
        [self.activityIndicator startAnimating];
        [self.progressView addSubview:self.progressLabel];
        [self.progressView addSubview:self.activityIndicator];
    }
    
    self.tableView.tableHeaderView = self.progressView;
    [self updateProgressView];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    SWWebServices *webServices = [[SWWebServices alloc] init];
    webServices.delegate = self;
    [webServices sendRequestForTopCharts];
}

- (void)processImages {
    dispatch_queue_t imageQueue = dispatch_queue_create("com.bg.imageDownloader", NULL);
    
    dispatch_async(imageQueue, ^void{
        
        for (Song *aSong in self.fetchedResultsController.fetchedObjects) {
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aSong.imageURL]];
            
            aSong.image = imageData;
            
            // Refresh the UI on main thread because UI should always be refreshed in main thread
            dispatch_async(dispatch_get_main_queue(), ^void{
                [self updateProgressView];
                
                NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:aSong];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }
        
        // Save the changes in main thread because the managed object context belongs to main thread
        // Also refresh the UI on main thread because UI should always be refreshed in main thread
        dispatch_async(dispatch_get_main_queue(), ^void{
            NSError *error = nil;
            
            if (![[AppDelegate managedObjectContext] save:&error]) {
                NSLog(@"Core Data Save Error: %@", [error localizedDescription]);
                
            } else {
                self.songsCount = -1;
                self.tableView.tableHeaderView = nil;
                self.fetchedResultsController = nil;
                [self.tableView reloadData];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        });
        
    });
}

- (void)openiTunesForSong:(NSString *)songURL {
    
    // Note: Does not wroks on simulator, should be tested on device.
    NSURL *url = [NSURL URLWithString:[songURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)updateProgressView {
    self.songsCount++;
    self.progressLabel.text = [NSString stringWithFormat:@"%d of 10 items done", self.songsCount];
}

@end
