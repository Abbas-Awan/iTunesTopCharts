//
//  SWSongInfoCell.m
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import "SWSongInfoCell.h"

#pragma mark - Private Interface

@interface SWSongInfoCell ()

@property (nonatomic) BOOL isGesturesAdded;

- (void)imageViewTapped:(UITapGestureRecognizer *)gesture;
- (void)setup;

@end

#pragma mark - Implementation

@implementation SWSongInfoCell

@synthesize activityIndicator = _activityIndicator;
@synthesize song = _song;
@synthesize delegate = _delegate;

- (void)setSong:(Song *)song {
    _song = song;
    
    if (song.image == nil) {
        UIImage *placeHolder = [UIImage imageNamed:@"Placeholder.png"];
        self.imageView.image = placeHolder;
        [self.activityIndicator startAnimating];
        
    } else {
        UIImage *image = [UIImage imageWithData:song.image];
        self.imageView.image = image;
        
        [self.activityIndicator stopAnimating];
    }
    
    self.textLabel.text = song.title;
    self.detailTextLabel.text = song.price;
}

#pragma mark - Init & Dealloc methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self setup];
}

#pragma mark - Private methods

- (void)imageViewTapped:(UITapGestureRecognizer *)gesture {
    
    if ([self.delegate respondsToSelector:@selector(swSongInfoCellImageViewTapped:)]) {
        [self.delegate swSongInfoCellImageViewTapped:self];
    }
}

- (void)setup {
    
    if (self.activityIndicator == nil) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.center = self.imageView.center;
        self.activityIndicator.hidesWhenStopped = YES;
        [self.contentView addSubview:self.activityIndicator];
    }
    
    if (self.song.image == nil) {
        UIImage *placeHolder = [UIImage imageNamed:@"Placeholder.png"];
        self.imageView.image = placeHolder;
        [self.activityIndicator startAnimating];
        
    } else {
        UIImage *image = [UIImage imageWithData:self.song.image];
        self.imageView.image = image;
    }
    
    if (!self.isGesturesAdded) {
        self.imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(imageViewTapped:)];
        gesture.numberOfTapsRequired = 1;
        [self.imageView addGestureRecognizer:gesture];
        
        self.isGesturesAdded = YES;
    }
}

@end
