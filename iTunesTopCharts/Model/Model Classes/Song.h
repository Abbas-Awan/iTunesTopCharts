//
//  Song.h
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * title;

@end
