//
//  Spot.h
//  PKProject
//
//  Created by Jordan on 10/1/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Spot : NSManagedObject

@property (nonatomic, retain) NSDate * createdOnDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * numberOfFavorites;
@property (nonatomic, retain) NSSet *spotPhoto;
@property (nonatomic, retain) NSManagedObject *createdByUser;
@end

@interface Spot (CoreDataGeneratedAccessors)

- (void)addSpotPhotoObject:(NSManagedObject *)value;
- (void)removeSpotPhotoObject:(NSManagedObject *)value;
- (void)addSpotPhoto:(NSSet *)values;
- (void)removeSpotPhoto:(NSSet *)values;

@end
