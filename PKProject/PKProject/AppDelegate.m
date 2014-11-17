//
//  AppDelegate.m
//  PKProject
//
//  Created by Jordan on 9/29/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "AppDelegate.h"
#import "Heap.h"
#import "CoreDataHandler.h"
#import "ServerHandler.h"
#import "SignUpViewController.h"
#import "User+Extended.h"

@interface AppDelegate ()

@property (nonatomic, weak) CoreDataHandler *coreDataHandler;

@end

@implementation AppDelegate {
    User *thisUser;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // default to having the sign in screen as the initial view
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"signIn"];
    
    [Heap setAppId:@"1618197093"];
#ifdef DEBUG
    [Heap enableVisualizer];
#endif
    
    // Logs 'install' and 'app activate' App Events with FacebookSDK
    [FBAppEvents activateApp];
    
    // FB login and token cacheing
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"session cached");

        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
        // override initial VC to go to the map
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"mapVC"];
        
        // If there's no cached session, update NSUserDefaults
    } else {
        NSLog(@"no session cached");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LoggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
        /* Other launch code goes here */
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Facebook SDK
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    NSLog(@"now logged out");

    // update value in NSUserDefaults so that other VC's can access
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LoggedIn"];
    // ??? do I def want to set this to nil?
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"thisUserFacebookId"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"thisUserFacebookName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    NSLog(@"now logged in");

    // update value in NSUserDefaults so that other VC's can access
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoggedIn"];
    
    [self getUserFacebookInformation];
}

-(void)getUserFacebookInformation {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            NSString *thisFBId = [result objectForKey:@"id"];
            NSString *thisFBName = [result objectForKey:@"name"];
            // save the user's facebookId
            [[NSUserDefaults standardUserDefaults] setObject:thisFBId forKey:@"thisUserFacebookId"];
            [[NSUserDefaults standardUserDefaults] setObject:thisFBName forKey:@"thisUserFacebookName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self updateOrCreateUserAccountWithData:result];
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            
            // TODO: show alert asking user to try logging out and logging in again
        }
    }];
}

-(void)updateOrCreateUserAccountWithData:(NSDictionary*)data {
    // call CoreDataHandler to either update or create new user
    NSString *thisUserId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];

    NSString *currentFacebookId = [data objectForKey:@"id"];
    CoreDataHandler *coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    // existing userId means the account has already been created on the server so we get the object for it
    if (thisUserId) {
        thisUser = [coreDataHandler getThisUser];
        
        // now we want to make sure this isn't a new user logged into the same device
        // if facebookId's match we are done
        if ([thisUser.facebookId isEqualToString:currentFacebookId]) {
            return;
        }
    }
    // if they don't match, need to get the right facebookId profile from the server
    [[ServerHandler sharedServerHandler] queryFacebookId:currentFacebookId handleResponse:^void (NSArray *queryResults) {
        // force to main thread for UI updates
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // if results are empty, create a new user from facebook info
            // TODO: nil check?
            if (queryResults.count == 1) {
                // account already exists so save it locally
                thisUser = (User*)[coreDataHandler createNew:@"User"];

                [thisUser updateFromDictionary:queryResults[0]];
                
                // update NSUserDefaults
                NSString *objectId = [queryResults[0] objectForKey:@"_id"];
                [[NSUserDefaults standardUserDefaults] setObject:objectId forKey:@"thisUserId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else if (queryResults.count == 0){
                // create a new user and fill it out with facebook info
                // TODO: popup to let user know their profile is being created?
                thisUser = (User*)[coreDataHandler createNew:@"User"];
                // pre-fills out user data from FB info and adds creation timestamp
                [thisUser updateFromFacebookDictionary:data];
                [[ServerHandler sharedServerHandler] pushUserToServer:thisUser];
            } else {
                // error
                NSLog(@"oh god how are there multiple accounts with this fb id?");
            }
            coreDataHandler.thisUser = thisUser;
        });
    }];
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
     }];
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

#pragma mark - UIApplication Handling

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.byjor.PKProject" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PKProject" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PKProject.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
