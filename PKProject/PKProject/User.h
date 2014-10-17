//
//  User.h
//  PKProject
//
//  Created by Jordan on 10/17/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"

@class Photo, Spot;

@interface User : ServerObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * creationTimestamp;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * nameFirst;
@property (nonatomic, retain) NSString * nameLast;
@property (nonatomic, retain) NSString * nameUser;
@property (nonatomic, retain) NSString * photoLocalPath;
@property (nonatomic, retain) NSString * photoOnlinePath;
@property (nonatomic, retain) NSSet *userCreatedPhoto;
@property (nonatomic, retain) NSSet *userCreatedSpot;
@property (nonatomic, retain) NSSet *userSpots;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUserCreatedPhotoObject:(Photo *)value;
- (void)removeUserCreatedPhotoObject:(Photo *)value;
- (void)addUserCreatedPhoto:(NSSet *)values;
- (void)removeUserCreatedPhoto:(NSSet *)values;

- (void)addUserCreatedSpotObject:(Spot *)value;
- (void)removeUserCreatedSpotObject:(Spot *)value;
- (void)addUserCreatedSpot:(NSSet *)values;
- (void)removeUserCreatedSpot:(NSSet *)values;

- (void)addUserSpotsObject:(Spot *)value;
- (void)removeUserSpotsObject:(Spot *)value;
- (void)addUserSpots:(NSSet *)values;
- (void)removeUserSpots:(NSSet *)values;

@end
