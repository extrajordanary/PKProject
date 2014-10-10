//
//  User+Extended.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "User+Extended.h"
#import "Photo.h"

@implementation User (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary {
    if (self) {
        // single values
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.city = dictionary[@"city"];
        self.country = dictionary[@"country"];
        self.email = dictionary[@"email"];
        self.nameFirst = dictionary[@"nameFirst"];
        self.nameLast = dictionary[@"nameLast"];
        self.nameUser = dictionary[@"nameUser"];
        self.databaseId = dictionary[@"_id"];
//        self.photo = dictionary[@"photo"];
//        self.createdOnDate = dictionary[@"createdOnDate"];
        
        // arrays of objects
//        self.userCreatedPhoto = dictionary[@"userCreatedPhoto"];
//        self.userSpot = dictionary[@"userSpot"];
//        self.userCreatedSpot = dictionary[@"userCreatedSpot"];
    }
}

-(NSDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    jsonable[@"creationTimestamp"] = self.creationTimestamp;
    jsonable[@"city"] = self.city;
    jsonable[@"country"] = self.country;
    jsonable[@"email"] = self.email;
    jsonable[@"nameFirst"] = self.nameFirst;
    jsonable[@"nameLast"] = self.nameLast;
    jsonable[@"nameUser"] = self.nameUser;
    jsonable[@"_id"] = self.databaseId;
    
    // photo ids
    jsonable[@"userCreatedPhoto"] = [self arrayOfObjectIds:self.userCreatedPhoto];
    
    // spot ids
    jsonable[@"userCreatedSpot"] = [self arrayOfObjectIds:self.userCreatedSpot];

    return jsonable;
}

//-(NSMutableArray*)arrayOfObjectIds:(NSSet*)objects {
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    for (ServerObjects *item in objects) {
//        [array addObject:item.databaseId];
//    }
//    return array;
//}

@end
