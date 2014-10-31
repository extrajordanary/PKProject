//
//  CoreDataHandler.m
//  PKProject
//
//  Created by Jordan on 10/22/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import "ServerObject+Extended.h"
#import "User+Extended.h"
#import "Spot+Extended.h"
#import "Photo+Extended.h"
#import "ServerHandler.h"

// for creating new mangaged objects and querying them

@implementation CoreDataHandler {
    NSManagedObjectContext *theContext;
    ServerHandler *serverHandler;
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
        serverHandler = [ServerHandler sharedServerHandler];
    }
    return self;
}

-(void)updateCoreData {
    // create error to pass to the save method
    NSError *error = nil;
    
    // save the context to persist changes
#pragma message "Make sure all calls to CoreData are happening on the MainThread, this could be causing the crash"
    [theContext save:&error]; // !!! Thread 4: EXC_BAD_ACCESS (code = 1, address=...)
    
    if (error) {
        // TODO: error handling
    }
}

#pragma mark - Create
-(ServerObject*)createNew:(NSString*)entityType {
    ServerObject* newEntitiy = [NSEntityDescription insertNewObjectForEntityForName:entityType inManagedObjectContext:theContext];
    return newEntitiy;
}

#pragma mark - Search
-(ServerObject*)getObjectWithDatabaseId:(NSString*)databaseId {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectModel* model = appDelegate.managedObjectModel;
    
    NSDictionary* substitutionDictionary = @{@"DATABASE_ID" : databaseId};
    NSFetchRequest* fetchRequest = [model fetchRequestFromTemplateWithName:@"existingObject"
                                                     substitutionVariables:substitutionDictionary];
    
    NSError *error;
    NSArray *results = [theContext executeFetchRequest:fetchRequest error:&error];
    if (results.count > 0)
    {
        return results[0];
    }
    return nil;
}

-(ServerObject*)returnObjectOfType:(NSString*)type forId:(NSString*)databaseId {

    ServerObject *object;
    object = [self getObjectWithDatabaseId:databaseId];
    if (!object) {
        // if the desired object doesn't already exist, create a new one
        object = [self createNew:type];
        [object setValue:databaseId forKey:@"databaseId"];
    }
    // update object from server
    [serverHandler updateObjectFromServer:object];
    return object;
}


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
