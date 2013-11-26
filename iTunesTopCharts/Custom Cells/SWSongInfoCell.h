//
//  SWSongInfoCell.h
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


#pragma mark -
@protocol SWSongInfoCellDelegate;


#pragma mark -

@interface SWSongInfoCell : UITableViewCell

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) Song *song;

@property (assign, nonatomic) id <SWSongInfoCellDelegate> delegate;

@end


#pragma mark -

@protocol SWSongInfoCellDelegate <NSObject>

@optional
- (void)swSongInfoCellImageViewTapped:(SWSongInfoCell *)cell;

@end