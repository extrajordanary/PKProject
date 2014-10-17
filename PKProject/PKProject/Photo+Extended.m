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

-(void)updateFromDictionary:(NSDictionary*)dictionary{
    if (self) {
        self.databaseId = dictionary[@"_id"];
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.latitude = dictionary[@"latitude"];
        self.longitude = dictionary[@"longitude"];
        
        // TODO: photoByUser - but I don't need to create these objects every time.
        // TODO: photoSpot
    }
}

-(NSDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    jsonable[@"creationTimestamp"] = self.creationTimestamp;
    jsonable[@"latitude"] = self.latitude;
    jsonable[@"longitude"] = self.longitude;
    jsonable[@"photoByUser"] = self.photoByUser.databaseId; // only one
    
    if (self.photoSpot.databaseId) {
        // in case the photo gets saved to the server before the spot does
        jsonable[@"photoSpot"] = self.photoSpot.databaseId; // only one
    }
    
    return jsonable;
}

/*
 // TODO: re-implement using fetching from local or online path
-(UIImage*)getImage {
    UIImage *image=[UIImage imageWithData:self.imageBinary];
    return image;
}
 */

@end
