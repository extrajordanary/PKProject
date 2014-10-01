//
//  User.h
//  PKProject
//
//  Created by Jordan on 10/1/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Spot;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * nameFirst;
@property (nonatomic, retain) NSString * nameLast;
@property (nonatomic, retain) NSString * nameUser;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSSet *userPhoto;
@property (nonatomic, retain) NSSet *userSpot;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUserPhotoObject:(NSManagedObject *)value;
- (void)removeUserPhotoObject:(NSManagedObject *)value;
- (void)addUserPhoto:(NSSet *)values;
- (void)removeUserPhoto:(NSSet *)values;

- (void)addUserSpotObject:(Spot *)value;
- (void)removeUserSpotObject:(Spot *)value;
- (void)addUserSpot:(NSSet *)values;
- (void)removeUserSpot:(NSSet *)values;

@end
