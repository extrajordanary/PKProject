//
//  ServerObject+Extended.m
//  PKProject
//
//  Created by Jordan on 10/10/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "ServerObject+Extended.h"
#import "AppDelegate.h"

@implementation ServerObject (Extended)

-(NSMutableArray*)arrayOfObjectIds:(NSArray*)objects {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (objects.count > 0) {
        for (ServerObject *item in objects) {
            if (item.databaseId) {
                [array addObject:item.databaseId];
            } else {
                [array addObject:@"0"];
            }
        }
    }
    return array;
}

-(void)updateCoreData {
    // create error to pass to the save method
    NSError *error = nil;
    
    // save the context to persist changes
    [((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext save:&error];
    
    if (error) {
        // TODO: error handling
    }
}

@end
