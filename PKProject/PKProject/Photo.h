//
//  Photo.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Spot, User;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * createdOnDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Spot *photoSpot;
@property (nonatomic, retain) User *photoByUser;

@end
