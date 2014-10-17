//
//  Spot.h
//  PKProject
//
//  Created by Jordan on 10/17/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"

@class Photo, User;

@interface Spot : ServerObject

@property (nonatomic, retain) NSString * creationTimestamp;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * numberOfFavorites;
@property (nonatomic, retain) User *spotByUser;
@property (nonatomic, retain) NSSet *spotPhotos;
@property (nonatomic, retain) NSSet *spotUsers;
@end

@interface Spot (CoreDataGeneratedAccessors)

- (void)addSpotPhotosObject:(Photo *)value;
- (void)removeSpotPhotosObject:(Photo *)value;
- (void)addSpotPhotos:(NSSet *)values;
- (void)removeSpotPhotos:(NSSet *)values;

- (void)addSpotUsersObject:(User *)value;
- (void)removeSpotUsersObject:(User *)value;
- (void)addSpotUsers:(NSSet *)values;
- (void)removeSpotUsers:(NSSet *)values;

@end
