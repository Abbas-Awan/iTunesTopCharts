//
//  Song+Custom.h
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import "Song.h"

@interface Song (Custom)

+ (Song *)newSongFromInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)moc;

+ (void)deleteAllSongsInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
