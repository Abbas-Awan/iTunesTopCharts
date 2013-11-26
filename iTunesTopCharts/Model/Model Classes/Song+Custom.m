//
//  Song+Custom.m
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import "Song+Custom.h"

@implementation Song (Custom)

+ (Song *)newSongFromInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)moc {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:moc];
    Song *newSong = [[Song alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    
    NSDictionary *titleInfo = [info valueForKey:@"title"];
    NSDictionary *priceInfo = [info valueForKey:@"im:price"];
    NSArray *linkInfo = [info valueForKey:@"link"];
    NSArray *imageInfo = [info valueForKey:@"im:image"];
    NSDictionary *linkAttributes;
    NSDictionary *image = [imageInfo lastObject];
    
    if ([linkInfo count] > 0) {
        linkAttributes = [[linkInfo objectAtIndex:0] valueForKey:@"attributes"];
    }
    
    newSong.title = [titleInfo valueForKey:@"label"];
    newSong.imageURL = [image valueForKey:@"label"];
    newSong.price = [priceInfo valueForKey:@"label"];
    newSong.link = [linkAttributes valueForKey:@"href"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"order"]];
    
    NSSet *existingIDs = [moc insertedObjects];
    NSInteger newID = 0;
    
    for (NSDictionary *dict in existingIDs) {
        NSInteger idToCompare = [[dict valueForKey:@"order"] integerValue];
        
        if (idToCompare >= newID) {
            newID = idToCompare + 1;
        }
    }
    
    NSNumber *order = [NSNumber numberWithInteger:newID];
    newSong.order = order;
    
    return newSong;
}

+ (void)deleteAllSongsInManagedObjectContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    fetchRequest.includesPropertyValues = NO; //only fetch the managedObjectID
    
    NSError *error;
    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[moc deleteObject:managedObject];
    }
    
    if (![moc save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@", entity, error);
    }
}

@end
