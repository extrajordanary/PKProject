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
#import "CoreDataHandler.h"
#import "User+Extended.h"
#import "Spot+Extended.h"
#import "Photo+Extended.h"
#import "PhotoCollectionViewCell.h"
#import "LocationManagerHandler.h"

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) User *thisUser;
@property (strong, nonatomic) NSMutableArray *nearbySpots;
@property (strong, nonatomic) IBOutlet UILabel *noSpotsText;

@end

@implementation MapViewController {
    ServerHandler *serverHandler;
    CoreDataHandler *coreDataHandler;
    LocationManagerHandler *locationHandler;
    NSString *thisUserId;
}

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

static const CGFloat kMetersPerMile = 1609.344;
static const CGFloat kDefaultZoomMiles = 0.5; // TODO : make dynamic/adjustable?

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    serverHandler = [ServerHandler sharedServerHandler];
    coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    locationHandler = [LocationManagerHandler sharedLocationManagerHandler];
    
    // listen for changes from location manager
    [locationHandler addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [locationHandler addObserver:self forKeyPath:@"isAuthorized" options:NSKeyValueObservingOptionNew context:nil];

    
//    [self startStandardMapUpdates];
    
    self.nearbySpots = [[NSMutableArray alloc] init];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self getThisUser];
    [self updateNearbySpots];
    
    if (locationHandler.isAuthorized) {
        [self zoomToCurrentLocation];
    }
}

#pragma mark - Location Manager
// TODO: create location manager singleton
// TODO: only zoom to location the first time
// TODO: search bar

//- (BOOL)startStandardMapUpdates
//{
//    // Create the location manager if this object does not already have one.
//    if (nil == self.locationManager) {
//        self.locationManager = [[CLLocationManager alloc] init];
//    }
//    
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//    
//    // Set a movement threshold for new events.
//    self.locationManager.distanceFilter = 500; // meters
//    
//    if(IS_OS_8_OR_LATER) {
//        [self.locationManager requestAlwaysAuthorization];
//    }
//
//    [self.locationManager startUpdatingLocation];
//    [self.locationManager startUpdatingHeading];
//
//    return YES;
//}

//- (BOOL)startStandardMapUpdates
//{
//    // Create the location manager if this object does not already have one.
//    if (nil == self.locationManager) {
//        self.locationManager = [[CLLocationManager alloc] init];
//    }
//    
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//    
//    // Set a movement threshold for new events.
//    self.locationManager.distanceFilter = 500; // meters
//    
//    if(IS_OS_8_OR_LATER) {
//        [self.locationManager requestAlwaysAuthorization];
//    }
//    
//    [self.locationManager startUpdatingLocation];
//    [self.locationManager startUpdatingHeading];
//    
//    return YES;
//}

// delegate method called when user changes authorization to allow location tracking
//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    if (status) {
//        [self zoomToCurrentLocation];
//    }
//}
//
//// Delegate method from the CLLocationManagerDelegate protocol.
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    [self zoomToCurrentLocation];
//
//}

#pragma mark - Map
- (IBAction)showUserLocation:(id)sender {
    [self zoomToCurrentLocation];
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationHandler.currentLocation.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

//-(void)zoomToCurrentLocation {
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
//    [self.mapView setRegion:viewRegion animated:YES];
//}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.nearbySpots count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell %i",(int)indexPath.row);
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
    if (!cell) {
        // ???
    }

    [cell.imageView setImage:[UIImage imageNamed:@"loadingSpotPhoto.jpg"]];
    [cell displayInfoForSpot:self.nearbySpots[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected cell %i",(int)indexPath.row);
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    // TODO: Highlight the appropriate marker on the map
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int height = collectionView.frame.size.height;

    return CGSizeMake(height, height); // create square cells at maximum height of CollectionView
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Spots
-(void)updateNearbySpots {
    // TODO: get only nearby spots based on coords, vs. all spots like now
    // TODO: how to handle offline use
    
    // get nearby spots from database, create Spot objects as needed, populate map
    [self.nearbySpots removeAllObjects];
    NSArray *allSpots = [[NSArray alloc] init];     // for debugging only
    allSpots = [coreDataHandler getManagedObjects:@"Spot"];     // for debugging only
    
    [serverHandler getSpotsFromServer:^void (NSDictionary *spots) {
        // force to main thread for UI updates
        dispatch_async(dispatch_get_main_queue(), ^(void){
            for (NSDictionary *serverSpot in spots) {
                // see if Spot object already exists in Core Data
                Spot *nextSpot;
                NSString *databaseId = serverSpot[@"_id"];

                nextSpot = (Spot*)[coreDataHandler getObjectWithDatabaseId:databaseId];
             
                // if Spot object doesn't already exist in Core Data, create it
                if (!nextSpot) {
    //                NSLog(@"new");
                    nextSpot = (Spot*)[coreDataHandler createNew:@"Spot"];
                }
    //            NSLog(@"    spot object");
                // update Spot from server info and then add to array
                [nextSpot updateFromDictionary:serverSpot];
                [self.nearbySpots addObject:nextSpot];
            }
        // force to main thread for UI updates
            if (self.nearbySpots.count > 0) {
                self.noSpotsText.hidden = YES;
                // TODO: should spot markers be children of the cells? Of the spots?
                [self placeSpotMarkers];
                [self.collectionView reloadData]; // populates scrollable photo previews
            } else {
                self.noSpotsText.hidden = NO;
            }
        });
    }];
}

// populates the map with pins at each Spot location
-(void)placeSpotMarkers {
    for (Spot *spot in self.nearbySpots) {
        // TODO: create custom MKPointAnnotation class for custom marker visuals
        MKPointAnnotation *spotMarker = [[MKPointAnnotation alloc] init];
        spotMarker.coordinate = [spot getCoordinate];
        [self.mapView addAnnotation:spotMarker];
    }
}

#pragma mark - Photos

#pragma mark - Users
-(void)getThisUser {
    thisUserId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];

// check if user has stored user _id, if not, create new user on server and save the _id
    if (!thisUserId) {
        // provide option to login with exisiting account
        
        // else create new user and save to server
        
        // save the returned objectID for thisUserId
        
        // cheating and hardcoding for now
        [[NSUserDefaults standardUserDefaults] setObject:@"542efcec4a1cef02006d1021" forKey:@"thisUserId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // see if User object already exists in Core Data
    NSPredicate *thisUser = [NSPredicate predicateWithFormat:@"databaseId = %@",thisUserId];
    NSSortDescriptor *sortBy = [NSSortDescriptor sortDescriptorWithKey:@"databaseId" ascending:YES];
    NSArray *searchResults = [coreDataHandler getManagedObjects:@"User" withPredicate:thisUser sortedBy:sortBy];
    
    if (searchResults.count > 0) {
        self.thisUser = searchResults[0];
    }
    
    if (!self.thisUser) {
        // if User object doesn't already exist in Core Data, create it and update from server
        User *newUser = (User*)[coreDataHandler createNew:@"User"];
        
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"thisUserId"];
        [newUser setValue:userId forKey:@"databaseId"];
        [serverHandler updateUserFromServer:newUser];

        self.thisUser = newUser;
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CreateSpot"]) {
        CreateSpotViewController *createSpotViewController = [segue destinationViewController];
        createSpotViewController.thisUser = self.thisUser;
//        createSpotViewController.locationManager = self.locationManager;
    }
}

- (IBAction)spotDoubleTap:(UITapGestureRecognizer *)sender {
    CGPoint tapLocation = [sender locationInView:self.collectionView];
    NSIndexPath *tappedIndexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    PhotoCollectionViewCell *tappedCell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:tappedIndexPath];

    [self viewSpotDetails:tappedCell.spot];
}

-(void)viewSpotDetails:(Spot*)spot {
    NSLog(@"view spot %@",spot.databaseId);
}

#pragma mark - Listeners
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self zoomToCurrentLocation];
    }
    else if([keyPath isEqualToString:@"isAuthorized"]) {
        if (locationHandler.isAuthorized) {
            [locationHandler startUpdatingLocation];
            [self zoomToCurrentLocation];
        }
    }
}

@end
