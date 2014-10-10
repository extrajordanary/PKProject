//
//  Photo.h
//  PKProject
//
//  Created by Jordan on 10/10/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"

@class Spot, User;

@interface Photo : ServerObject

@property (nonatomic, retain) NSString * creationTimestamp;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) User *photoByUser;
@property (nonatomic, retain) Spot *photoSpot;

@end
