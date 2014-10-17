//
//  Spot+Extended.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Spot+Extended.h"
#import "User+Extended.h"
#import "Photo+Extended.h"
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
        // TODO: create User object
        // TODO: create Photo objects
    }
}

-(NSDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    jsonable[@"creationTimestamp"] = self.creationTimestamp;
    jsonable[@"latitude"] = self.latitude;
    jsonable[@"longitude"] = self.longitude;
    jsonable[@"numberOfFavorites"] = self.numberOfFavorites;
    jsonable[@"spotByUser"] = self.spotByUser.databaseId;
    
    // create and save array of photo databaseIds
    if (self.spotPhotos) {
        jsonable[@"spotPhotos"] = [self arrayOfObjectIds:self.spotPhotos.allObjects];
    }
    
    return jsonable;
}

-(UIImage*)getThumbnail {
    UIImage *image;
    if (self.spotPhotos.allObjects.count > 0) {
//        Photo *firstPhoto = self.spotPhotos.allObjects[0];
//        image = [firstPhoto getImage];
        image = [UIImage imageNamed:@"defaultSpotPhoto.jpg"]; // !!! - hotfix
        NSLog(@"photo");
    } else {
        image = [UIImage imageNamed:@"noSpotPhoto.jpg"];
        NSLog(@"no photo");
    }
    return image;
}

-(CLLocationCoordinate2D)getCoordinate {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    return coord;
}

@end
