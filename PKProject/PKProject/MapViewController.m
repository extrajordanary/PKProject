//
//  MapViewController.m
//  PKProject
//
//  Created by Jordan on 9/30/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "DatabaseHandler.h"
#import "User+Extended.h"

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mainMap;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) User *myUser;

@end

#define METERS_PER_MILE 1609.344
#define DEFAULT_ZOOM_MILES .2

@implementation MapViewController {
    NSManagedObjectContext *theContext;

//    NSString *myUserId;
//    NSDictionary *myUserInfo;
    DatabaseHandler *databaseHandler;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    theContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    databaseHandler = [DatabaseHandler sharedDatabaseHandler];
    
    [self startStandardMapUpdates];
    
    self.mainMap.showsUserLocation = YES;
    self.mainMap.showsPointsOfInterest = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // get list of Users in Core Data
    NSArray *userList = [[NSArray alloc] init];
    userList = [self getManagedObjects:@"User"];
    
    if ([userList count]<10) {
        // create a sample user to test pulling info from the server
        self.myUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:theContext];
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
        [self.myUser setValue:userId forKey:@"databaseId"];
        [databaseHandler updateUserFromDatabase:self.myUser];
        
        // create error to pass to the save method
        NSError *error = nil;
        
        // attempt to save the context to persist changes
        [theContext save:&error];
        
        if (error) {
            // error handling
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location Manager

- (BOOL)startStandardMapUpdates
{
    // Create the location manager if this object does not already have one.
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500; // meters
    
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    return YES;
}

// delegate method called when user changes authorization to allow location tracking
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, DEFAULT_ZOOM_MILES*METERS_PER_MILE, DEFAULT_ZOOM_MILES*METERS_PER_MILE);
        [self.mainMap setRegion:viewRegion animated:YES];
    }
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    
    //    NSDate* eventDate = location.timestamp;
    //    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
//        if (abs(howRecent) < 15.0) {
    // If the event is recent, do something with it.
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
//        }
}

# pragma mark - Managed Objects
- (void)createSampleData {
    // create sample users
    
    // create sample spots
    
    // create sample photos
    
    // assign connections between them
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"CreateSpot"]) {
        // transition to edit spot view
    }
}


@end
