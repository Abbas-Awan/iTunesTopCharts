//
//  SWWebServices.h
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark -

@protocol SWWebServicesDelegate;


#pragma mark -

@interface SWWebServices : NSObject

- (void)sendRequestForTopCharts;

@property (assign, nonatomic) id <SWWebServicesDelegate> delegate;

@end


#pragma mark -

@protocol SWWebServicesDelegate <NSObject>

@optional
- (void)swWebServices:(SWWebServices *)request failedWithError:(NSError *)error;
- (void)swWebServices:(SWWebServices *)request finishedWithList:(NSArray *)songsList;

@end