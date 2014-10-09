//
//  User+Extended.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "User+Extended.h"

@implementation User (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary {
    if (self) {
        // single values
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

@end
