//
//  Photo+Extended.m
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Photo+Extended.h"
#import "Spot+Extended.h"
#import "User+Extended.h"

@implementation Photo (Extended)

//@dynamic image;

-(void)updateFromDictionary:(NSDictionary*)dictionary{
    if (self) {
        self.databaseId = dictionary[@"_id"];
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.latitude = dictionary[@"latitude"];
        self.longitude = dictionary[@"longitude"];
//        self.imageBinary = dictionary[@"imageBinary"];
        
        // photoByUser - but I don't need to create these objects every time...
        // photoSpot
    }
}

-(NSDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    // do I ever need to include _id in this?
//    if (self.databaseId) {
//        jsonable[@"_id"] = self.databaseId;
//    }
    jsonable[@"creationTimestamp"] = self.creationTimestamp;
    jsonable[@"latitude"] = self.latitude;
    jsonable[@"longitude"] = self.longitude;
//    jsonable[@"imageBinary"] = self.imageBinary;

    jsonable[@"photoByUser"] = self.photoByUser.databaseId; // only one
    
    if (self.photoSpot.databaseId) {
        // in case the photo gets saved to the server before the spot does
        jsonable[@"photoSpot"] = self.photoSpot.databaseId; // only one
    }
    
    return jsonable;
}

-(UIImage*)getImage {
    UIImage *image=[UIImage imageWithData:self.imageBinary];
    return image;
}

@end
