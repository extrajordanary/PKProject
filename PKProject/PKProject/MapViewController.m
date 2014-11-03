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

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) User *thisUser;
@property (strong, nonatomic) NSMutableArray *nearbySpots;
@property (strong, nonatomic) IBOutlet UILabel *noSpotsText;

@end

@implementation MapViewController {
    ServerHandler *serverHandler;
    CoreDataHandler *coreDataHandler;
    NSString *thisUserId;
}

static const CGFloat kMetersPerMile = 1609.344;
static const CGFloat kDefaultZoomMiles = 0.5; // TODO : make dynamic/adjustable?

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    serverHandler = [ServerHandler sharedServerHandler];
    coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    
    [self startStandardMapUpdates];
    
    self.nearbySpots = [[NSMutableArray alloc] init];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self getThisUser];
    [self updateNearbySpots];
}

#pragma mark - Location Manager
// TODO: create location manager singleton
// TODO: only zoom to location the first time
// TODO: search bar
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
//    NSLog(@"latitude %+.6f, longitude %+.6f\n",
//          location.coordinate.latitude,
//          location.coordinate.longitude);
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

#pragma mark - UICollectionView
// Will use this when user touches marker on map
//- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.nearbySpots count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell %i",(int)indexPath.row);
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
    if (!cell) {
        
    }
//    cell.spot = self.nearbySpots[indexPath.row];
    
    // TODO: create method for cell to load images asynchronously for when they'll be downloading from online
//    UIImage *image = [cell.spot getThumbnail]; // returns image for first Photo object
//    [cell.imageView setImage:image];
    [cell.imageView setImage:[UIImage imageNamed:@"loadingSpotPhoto.jpg"]];
    [cell displayInfoForSpot:self.nearbySpots[indexPath.row]];
    
    return cell;
}
// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout
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
//        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (self.nearbySpots.count > 0) {
                self.noSpotsText.hidden = YES;
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
//        User *newUser = [coreDataHandler newUser];
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
        createSpotViewController.locationManager = self.locationManager;
    }
}

@end
