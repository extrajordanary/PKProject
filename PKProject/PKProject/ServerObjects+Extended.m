//
//  ServerObjects.m
//  PKProject
//
//  Created by Jordan on 10/10/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "ServerObjects.h"

@implementation ServerObjects

@synthesize databaseId;

-(NSMutableArray*)arrayOfObjectIds:(NSSet*)objects {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (ServerObjects *item in objects) {
        [array addObject:item.databaseId];
    }
    return array;
}

@end
