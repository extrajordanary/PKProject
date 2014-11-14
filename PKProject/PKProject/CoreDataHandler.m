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
    
    NSString *thisUserId;
    NSString *thisUserFacebookId;
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
        theContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        serverHandler = [ServerHandler sharedServerHandler];
    }
    return self;
}

-(void)updateCoreData {
    // force to main thread to avoid access conflicts between different threads
    dispatch_async(dispatch_get_main_queue(), ^(void){
        // create error to pass to the save method
        NSError *error = nil;
        
        // save the context to persist changes
        [theContext save:&error]; // !!! Thread 4: EXC_BAD_ACCESS (code = 1, address=...)
        
        if (error) {
            // TODO: error handling
        }
    });

}

#pragma mark - Create
-(ServerObject*)createNew:(NSString*)entityType {
        ServerObject* newEntitiy = [NSEntityDescription insertNewObjectForEntityForName:entityType inManagedObjectContext:theContext];
        return newEntitiy;
}

#pragma mark - Users
-(void)updateThisUser {
    thisUserId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
    thisUserFacebookId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserFacebookId"];
    
    // get core data object for this user
    [self getThisUser];

    if (self.thisUser) {
        // does the facebookId match?
    }
    
    
    // TODO: check if user has existing User profile, if not create one
    // check CoreData first then Server
    // TODO: check Core Data
    NSString *userFacebookId = @"10103934015298835"; // hardcode cheating for now
    [[ServerHandler sharedServerHandler] queryFacebookId:userFacebookId handleResponse:^void (NSArray *queryResults) {
        // force to main thread for UI updates
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // if results are empty, create a new user from facebook info
            if (queryResults.count == 0) {
                
            } else {
                // else update existing user
                
            }
        });
    }];
}

// returns the User object for this device's user profile, may return nil
-(User*)getThisUser {
    NSLog(@"getting this user");
    thisUserId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
//    thisUserFacebookId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserFacebookId"];

    // check if user has stored user _id, if not, create new user on server and save the _id
    // ??? redundant?
    if (!thisUserId) {
        // expected case for when user is creating account for the first time or logging in on a new device
        return nil;
        // cheating and hardcoding for now
//        [[NSUserDefaults standardUserDefaults] setObject:@"542efcec4a1cef02006d1021" forKey:@"thisUserId"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // we have a userId so the object must exist on the server
    // first see if User object already exists in Core Data
    self.thisUser = (User*)[self returnObjectOfType:@"User" forId:thisUserId];
    
    
    // TODO: change this out for the generic search
//    NSPredicate *thisUser = [NSPredicate predicateWithFormat:@"databaseId = %@",thisUserId];
//    NSSortDescriptor *sortBy = [NSSortDescriptor sortDescriptorWithKey:@"databaseId" ascending:YES];
//    NSArray *searchResults = [self getManagedObjects:@"User" withPredicate:thisUser sortedBy:sortBy];
//    
//    if (searchResults.count > 0) {
//        self.thisUser = searchResults[0];
//
//    }
    
//    if (!self.thisUser) {
//        // if User object doesn't already exist in Core Data, create it and update from server
//        User *newUser = (User*)[self createNew:@"User"];
//        
//        
//        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
//        [newUser setValue:userId forKey:@"databaseId"];
//        [serverHandler updateUserFromServer:newUser];
//        
//        self.thisUser = newUser;
//    }
    
    return self.thisUser;
}

#pragma mark - Search
// searches for existing core data objects with given databaseId
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

// returns the requested object by finding or creating the core data object
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
