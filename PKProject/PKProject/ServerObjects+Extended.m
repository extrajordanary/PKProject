//
//  ServerObject+Extended.m
//  PKProject
//
//  Created by Jordan on 10/10/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "ServerObject+Extended.h"
#import "AppDelegate.h"
#import "CoreDataHandler.h"

@implementation ServerObject (Extended)

// for getting an array of databaseIds to save on the server
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
    CoreDataHandler *coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    [coreDataHandler updateCoreData];
}

@end
