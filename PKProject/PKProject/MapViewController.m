//
//  MapViewController.m
//  PKProject
//
//  Created by Jordan on 9/30/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "CreateSpotViewController.h"
#import "ServerHandler.h"
#import "User+Extended.h"
#import "Spot+Extended.h"

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) User *thisUser;
@property (strong, nonatomic) NSMutableArray *nearbySpots;



@end

//#define METERS_PER_MILE 1609.344
//#define DEFAULT_ZOOM_MILES 2

@implementation MapViewController {
    NSManagedObjectContext *theContext;
    ServerHandler *serverHandler;
    NSString *thisUserId;
}

static const CGFloat kMetersPerMile = 1609.344;
static const CGFloat kDefaultZoomMiles = 0.5;

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    theContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    serverHandler = [ServerHandler sharedServerHandler];
    
    [self startStandardMapUpdates];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // get list of Users in Core Data
    NSArray *userList = [[NSArray alloc] init];
    userList = [self getManagedObjects:@"User"];
    
    if ([userList count]<1) {
        // create a sample user to test pulling info from the server
        User *aUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:theContext];
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
        [aUser setValue:userId forKey:@"databaseId"];
        [serverHandler updateUserFromServer:aUser];
        
        // create error to pass to the save method
        NSError *error = nil;
        
        // attempt to save the context to persist changes
        [theContext save:&error];
        
        if (error) {
            // TODO: error handling
        }
    }
    
    // get User object for this user
    // should always be one since appDelegate deals with case when none exists
    // TODO: user isn't updated from server by the time this is called
    thisUserId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
    NSPredicate *thisUser = [NSPredicate predicateWithFormat:@"databaseId = %@",thisUserId];
    NSSortDescriptor *sortBy = [NSSortDescriptor sortDescriptorWithKey:@"databaseId" ascending:YES];
    self.thisUser = [self getManagedObjects:@"User" withPredicate:thisUser sortedBy:sortBy][0];

    // get spots from server
    [self updateNearbySpots];
    // create marker on map for each spot
//    [self placeSpotMarkers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location Manager
// TODO: create location manager singleton
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
        [self zoomToCurrentLocation];
    }
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    [self zoomToCurrentLocation];
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

#pragma mark - Spots
-(void)updateNearbySpots {
    // get nearby spots from database, create Spot objects, add to array
    self.nearbySpots = [[NSMutableArray alloc] init];
    [serverHandler getSpotsFromServer:^void (NSDictionary *spots) {
        for (NSDictionary *item in spots) {
            Spot *newSpot = [NSEntityDescription insertNewObjectForEntityForName:@"Spot" inManagedObjectContext:theContext];
            [newSpot updateFromDictionary:item];
            [self.nearbySpots addObject:newSpot];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self placeSpotMarkers];
        });
    }];
}

-(void)placeSpotMarkers {
    for (Spot *spot in self.nearbySpots) {
        MKPointAnnotation *spotMarker = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([spot.latitude doubleValue], [spot.longitude doubleValue]);
        spotMarker.coordinate = coord;
        [self.mapView addAnnotation:spotMarker];
    }
}

#pragma mark - Core Data
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CreateSpot"]) {
        CreateSpotViewController *createSpotViewController = [segue destinationViewController];
        createSpotViewController.thisUser = self.thisUser;
        createSpotViewController.locationManager = self.locationManager;
    }
}


@end
