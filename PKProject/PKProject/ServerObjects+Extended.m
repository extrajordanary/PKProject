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

// for getting an array of databaseIds from relationship Objects to save on the server
-(NSMutableArray*)arrayOfObjectIds:(NSArray*)relationshipObjects {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (relationshipObjects.count > 0) {
        for (ServerObject *item in relationshipObjects) {
            if (item.databaseId) {
                [array addObject:item.databaseId];
            } else {
                // if object not yet saved to the server and has no database id
                // assign it the default value so that the array will at least know the correct number of objects
                [array addObject:@"0"];
            }
        }
    }
    return array;
}

//-(NSArray*)getManagedObjects:(NSString*)entityForName withPredicate:(NSPredicate*)predicate {
//    CoreDataHandler *coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
//    [coreDataHandler getManagedObjects:entityForName withPredicate:predicate];
//}

-(void)updateCoreData {
    // don't save if
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (self.databaseId) {
            CoreDataHandler *coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
            [coreDataHandler updateCoreData];
        }
    });
}

@end
