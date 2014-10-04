//
//  Spot.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, User;

@interface Spot : NSManagedObject

@property (nonatomic, retain) NSDate * createdOnDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * numberOfFavorites;
@property (nonatomic, retain) NSSet *spotPhoto;
@property (nonatomic, retain) User *spotByUser;
@end

@interface Spot (CoreDataGeneratedAccessors)

- (void)addSpotPhotoObject:(Photo *)value;
- (void)removeSpotPhotoObject:(Photo *)value;
- (void)addSpotPhoto:(NSSet *)values;
- (void)removeSpotPhoto:(NSSet *)values;

@end
