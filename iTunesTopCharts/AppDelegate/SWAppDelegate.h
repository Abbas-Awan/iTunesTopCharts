//
//  SWAppDelegate.h
//  iTunesTopCharts
//
//  Created by Abbas Ali on 11/26/13.
//  Copyright (c) 2013 SalamWorld. All rights reserved.
//

#import <UIKit/UIKit.h>


#define AppDelegate (SWAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface SWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

@end
