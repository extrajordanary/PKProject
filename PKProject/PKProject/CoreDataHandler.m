//
//  CoreDataHandler.m
//  PKProject
//
//  Created by Jordan on 10/22/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import "User+Extended.h"
#import "Spot+Extended.h"
#import "Photo+Extended.h"

// for creating new mangaged objects and querying them

@implementation CoreDataHandler {
    NSManagedObjectContext *theContext;
}

#pragma mark - Singleton Methods
+ (id)sharedCoreDataHandler {
    static CoreDataHandler *sharedCoreDataHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoreDataHandler = [[self alloc] init];
    });
    return sharedCoreDataHandler;
}

- (id)init {
    if (self = [super init]) {
        // ??? - Anything to include here?
        theContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    return self;
}

-(void)updateCoreData {
    // create error to pass to the save method
    NSError *error = nil;
    
    // save the context to persist changes
    [theContext save:&error];
    
    if (error) {
        // TODO: error handling
    }
}

#pragma mark - Create
-(User*)newUser {
    User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:theContext];
    return newUser;
}

-(Spot*)newSpot {
    Spot *newSpot = [NSEntityDescription insertNewObjectForEntityForName:@"Spot" inManagedObjectContext:theContext];
    return newSpot;
}

-(Photo*)newPhoto {
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:theContext];
    return newPhoto;
}


#pragma mark - Search
-(NSArray*)getManagedObjects:(NSString*)entityForName {
    // get entity description for entity we are selecting
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityForName inManagedObjectContext:theContext];
    // create a new fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // create an error variable to pass to the execute method
    NSError *error;
    
    // retrieve results
    NSArray *array = [theContext executeFetchRequest:request error:&error];
    if (array == nil) {
        //error handling, e.g. display err
    }
    return array;
}

-(NSArray*)getManagedObjects:(NSString*)entityForName withPredicate:(NSPredicate*)predicate {
    // get entity description for entity we are selecting
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityForName inManagedObjectContext:theContext];
    // create a new fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // apply a filter by creating a predicate and adding it to the request
    [request setPredicate:predicate];
    
    // create an error variable to pass to the execute method
    NSError *error;
    
    // retrieve results
    NSArray *array = [theContext executeFetchRequest:request error:&error];
    if (array == nil) {
        //error handling, e.g. display err
    }
    return array;
}

-(NSArray*)getManagedObjects:(NSString*)entityForName withPredicate:(NSPredicate*)predicate sortedBy:(NSSortDescriptor*)sortDescriptor{
    // get entity description for entity we are selecting
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityForName inManagedObjectContext:theContext];
    // create a new fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // apply a filter by creating a predicate and adding it to the request
    [request setPredicate:predicate];
    
    // create a sort rule and add it to the request
    [request setSortDescriptors:@[sortDescriptor]];
    
    // create an error variable to pass to the execute method
    NSError *error;
    
    // retrieve results
    NSArray *array = [theContext executeFetchRequest:request error:&error];
    if (array == nil) {
        //error handling, e.g. display err
    }
    return array;
}

@end
