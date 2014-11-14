//
//  User+Extended.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "User+Extended.h"
#import "ServerObject+Extended.h"
#import "Photo+Extended.h"

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
        self.facebookId = dictionary[@"facebookId"];
        self.databaseId = dictionary[@"_id"];
        
        // TODO: create Photo objects
        // TODO: create Spot objects

        [self updateCoreData];
    }
}

// called when new account is created to prepopulate fields from Facebook info
-(void)updateFromFacebookDictionary:(NSDictionary*)dictionary {
    NSLog(@"updating from facebook");
    self.facebookId = dictionary[@"id"];
    self.nameFirst = dictionary[@"first_name"];
    self.nameLast = dictionary[@"last_name"];
    self.email = dictionary[@"email"];
    
    [self updateCoreData];
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
    jsonable[@"facebookId"] = self.facebookId;
    
    // photo ids
    jsonable[@"userCreatedPhoto"] = [self arrayOfObjectIds:[self.userCreatedPhoto allObjects]];
    
    // spot ids
    jsonable[@"userCreatedSpot"] = [self arrayOfObjectIds:[self.userCreatedSpot allObjects]];

    return jsonable;
}

@end
