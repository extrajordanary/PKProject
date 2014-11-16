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

@property (strong, nonatomic) User *thisUser;

-(ServerObject*)getObjectWithDatabaseId:(NSString*)databaseId;
-(ServerObject*)returnObjectOfType:(NSString*)type forId:(NSString*)databaseId;

-(NSArray*)getManagedObjects:(NSString*)entityForName;
-(NSArray*)getManagedObjects:(NSString*)entityForName withPredicate:(NSPredicate*)predicate;
-(NSArray*)getManagedObjects:(NSString*)entityForName
               withPredicate:(NSPredicate*)predicate
                    sortedBy:(NSSortDescriptor*)sortDescriptor;

-(ServerObject*)createNew:(NSString*)entityType;

-(User*)getThisUser;
//-(void)updateThisUser;

-(void)updateCoreData;

@end
