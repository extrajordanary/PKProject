//
//  CoreDataHandler.h
//  PKProject
//
//  Created by Jordan on 10/22/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class User;
@class Spot;
@class Photo;
@class ServerObject;

@interface CoreDataHandler : NSObject

+ (id)sharedCoreDataHandler;

-(Spot*)getSpotWithDatabaseId:(NSString*)databaseId;
-(NSArray*)getManagedObjects:(NSString*)entityForName;
-(NSArray*)getManagedObjects:(NSString*)entityForName withPredicate:(NSPredicate*)predicate;
-(NSArray*)getManagedObjects:(NSString*)entityForName
               withPredicate:(NSPredicate*)predicate
                    sortedBy:(NSSortDescriptor*)sortDescriptor;
-(User*)newUser;
-(Spot*)newSpot;
-(Photo*)newPhoto;

-(void)updateCoreData;

@end
