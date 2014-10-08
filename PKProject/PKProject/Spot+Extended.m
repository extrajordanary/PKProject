//
//  Spot+Extended.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Spot+Extended.h"

@implementation Spot (Extended)

// for initializing from database results
-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    [self updateFromDictionary:dictionary];
    return self;
}

-(void)updateFromDictionary:(NSDictionary*)dictionary{
    if (self) {
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.latitude = dictionary[@"latitude"];
        self.longitude = dictionary[@"longitude"];
        self.numberOfFavorites = dictionary[@"numberOfFavorites"];
        // spot photos
        self.spotByUser = dictionary[@"spotByUser"];
    }
}

-(NSDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    jsonable[@"creationTimestamp"] = self.creationTimestamp;
    jsonable[@"latitude"] = self.latitude;
    jsonable[@"longitude"] = self.longitude;
    jsonable[@"numberOfFavorites"] = self.numberOfFavorites;
    // spot photos
    jsonable[@"spotByUser"] = self.spotByUser;
    
    return jsonable;
}

@end
