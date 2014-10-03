//
//  User.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Spot;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * nameFirst;
@property (nonatomic, retain) NSString * nameLast;
@property (nonatomic, retain) NSString * nameUser;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDate * createdOnDate;
@property (nonatomic, retain) NSSet *userCreatedPhoto;
@property (nonatomic, retain) NSSet *userSpot;
@property (nonatomic, retain) Spot *userCreatedSpot;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUserCreatedPhotoObject:(Photo *)value;
- (void)removeUserCreatedPhotoObject:(Photo *)value;
- (void)addUserCreatedPhoto:(NSSet *)values;
- (void)removeUserCreatedPhoto:(NSSet *)values;

- (void)addUserSpotObject:(Spot *)value;
- (void)removeUserSpotObject:(Spot *)value;
- (void)addUserSpot:(NSSet *)values;
- (void)removeUserSpot:(NSSet *)values;

@end
