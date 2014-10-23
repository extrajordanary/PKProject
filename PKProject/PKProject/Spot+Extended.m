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
        [self createAndAddUser:dictionary[@"spotByUser"]];
        // TODO: create Photo objects
        
        [self updateCoreData];
    }
}

-(void)createAndAddUser:(NSArray*)array {
   /* for (NSString *databaseId in array) {
        CoreDataHandler *coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
        User *user;
        // see if User object already exists in Core Data
        NSPredicate *aUser = [NSPredicate predicateWithFormat:@"databaseId = %@",databaseId];
//        NSSortDescriptor *sortBy = [NSSortDescriptor sortDescriptorWithKey:@"databaseId" ascending:YES];
        NSArray *searchResults = [coreDataHandler getManagedObjects:@"User" withPredicate:aUser];
        if (searchResults.count > 0) {
            user = searchResults[0];
        }
        
        if (!user) {
            // if User object doesn't already exist in Core Data, create it and update from server
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:theContext];
            
            NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
            [newUser setValue:userId forKey:@"databaseId"];
            [serverHandler updateUserFromServer:newUser];
            
            self.aUser = newUser;
        }
   }
    */
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
    // if there are Photo objects associated with this spot, get the image of the first one
    if (self.spotPhotos.allObjects.count > 0) {
        Photo *firstPhoto = self.spotPhotos.allObjects[0];
        image = [firstPhoto getImage];
        NSLog(@"photo");
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
