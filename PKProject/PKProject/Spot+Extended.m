//
//  Spot+Extended.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Spot+Extended.h"
#import "User+Extended.h"
#import "ServerObject+Extended.h"

@implementation Spot (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary{
    if (self) {
        self.databaseId = dictionary[@"_id"];
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.latitude = dictionary[@"latitude"];
        self.longitude = dictionary[@"longitude"];
        self.numberOfFavorites = dictionary[@"numberOfFavorites"];
        // photos and users need to be connected by seeing if core data object with that id already exists
        // if not pull and create it before setting up the connection
        // spot photos
//        self.spotByUser = dictionary[@"spotByUser"];
    }
}

-(NSDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    jsonable[@"creationTimestamp"] = self.creationTimestamp;
    jsonable[@"latitude"] = self.latitude;
    jsonable[@"longitude"] = self.longitude;
    jsonable[@"numberOfFavorites"] = self.numberOfFavorites;
    jsonable[@"spotByUser"] = self.spotByUser.databaseId;
    
    // photo ids
    jsonable[@"userCreatedPhoto"] = [self arrayOfObjectIds:self.spotPhotos.allObjects];
    
    return jsonable;
}

@end
