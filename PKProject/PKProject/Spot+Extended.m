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
#import "CoreDataHandler.h"
//#import "ServerHandler.h"

@implementation Spot (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary{
    if (self) {
        self.databaseId = dictionary[@"_id"];
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.latitude = dictionary[@"latitude"];
        self.longitude = dictionary[@"longitude"];
        self.numberOfFavorites = dictionary[@"numberOfFavorites"];

        // TODO: each of the following two gets the CoreDataHandler, redundancy
        [self updateSpotByUser:dictionary[@"spotByUser"]];
        [self updateSpotPhotos:dictionary[@"spotPhotos"]];
        
        [self updateCoreData];
    }
}

-(void)updateSpotByUser:(NSString*)databaseId {
    CoreDataHandler *coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    User *user;
    // coreDataHandler gets or creates the User object and updates it from the server
    user = (User*)[coreDataHandler returnObjectOfType:@"User" forId:databaseId];
    [self setSpotByUser:user];
}

-(void)updateSpotPhotos:(NSArray*)databaseIds {
    CoreDataHandler *coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    for (NSString *databaseId in databaseIds) {
        Photo *photo;
        // coreDataHandler gets or creates the User object and updates it from the server
#pragma message "Got the enumeration issue here once"
        photo = (Photo*)[coreDataHandler returnObjectOfType:@"Photo" forId:databaseId];
        [self addSpotPhotosObject:photo];
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
    NSLog(@"getting photo...");
    // if there are Photo objects associated with this spot, get the image of the first one
    if (self.spotPhotos.allObjects.count > 0) {
        Photo *firstPhoto = self.spotPhotos.allObjects[0];
        image = [firstPhoto getImage];
    }
    // if there are no Photo objects or the returned value is nil, use the "no image found" photo
    if (!image) {
        image = [UIImage imageNamed:@"noSpotPhoto.jpg"];
        NSLog(@"no photo found");
    }
    return image;
}

-(CLLocationCoordinate2D)getCoordinate {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    return coord;
}

@end
