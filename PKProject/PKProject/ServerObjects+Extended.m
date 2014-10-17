//
//  ServerObject+Extended.m
//  PKProject
//
//  Created by Jordan on 10/10/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "ServerObject+Extended.h"

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

@end
