//
//  Spot.h
//  PKProject
//
//  Created by Jordan on 10/9/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObjects.h"

@class Photo, User;

@interface Spot : ServerObjects

@property (nonatomic, retain) NSString * creationTimestamp;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * numberOfFavorites;
@property (nonatomic, retain) NSString * databaseId;
@property (nonatomic, retain) User *spotByUser;
@property (nonatomic, retain) NSSet *spotPhoto;
@end

@interface Spot (CoreDataGeneratedAccessors)

- (void)addSpotPhotoObject:(Photo *)value;
- (void)removeSpotPhotoObject:(Photo *)value;
- (void)addSpotPhoto:(NSSet *)values;
- (void)removeSpotPhoto:(NSSet *)values;

@end
