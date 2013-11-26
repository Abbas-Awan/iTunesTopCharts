//
//  SWWebServices.m
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import "SWWebServices.h"

NSString* const topChartsURL = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topsongs/limit=10/json";

#pragma mark - Private Interface

@interface SWWebServices () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *data;

- (void)parseData:(NSData *)data;

@end

#pragma mark - Implementation

@implementation SWWebServices

@synthesize data = _data;
@synthesize delegate = _delegate;

- (void)sendRequestForTopCharts {
    NSURL *url = [[NSURL alloc] initWithString:topChartsURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (urlConnection) {
        NSLog(@"Connection is true for %@", [request URL]);
        self.data = [[NSMutableData alloc] init];
    }
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
    if ([self.delegate respondsToSelector:@selector(swWebServices:failedWithError:)]) {
        [self.delegate swWebServices:self failedWithError:error];
    }
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __FUNCTION__);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"%s", __FUNCTION__);
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%s", __FUNCTION__);
    
    [self parseData:self.data];
}

#pragma mark - Private methods

- (void)parseData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *feed = [json valueForKey:@"feed"];
    NSArray *songs = [feed valueForKey:@"entry"];
    
    if ([self.delegate respondsToSelector:@selector(swWebServices:finishedWithList:)]) {
        [self.delegate swWebServices:self finishedWithList:songs];
    }
}

@end
