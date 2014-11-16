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
#import "MKAnnotationCustom.h"

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) User *thisUser;
@property (strong, nonatomic) NSMutableArray *nearbySpots;
@property (strong, nonatomic) NSMutableArray *annotationViews;
@property (strong, nonatomic) IBOutlet UILabel *noSpotsText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MapViewController {
    ServerHandler *serverHandler;
    CoreDataHandler *coreDataHandler;
    LocationManagerHandler *locationHandler;
    CGPoint collectionViewCenter;
    UIWindow *mainWindow;
    NSString *thisUserId;
    BOOL firstZoom;
    int cellWidth;
}

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

static const CGFloat kMetersPerMile = 1609.344;
static const CGFloat kDefaultZoomMiles = 0.5;

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

    self.nearbySpots = [[NSMutableArray alloc] init];
    self.annotationViews = [[NSMutableArray alloc] init];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.delegate = self;
    
    self.thisUser = coreDataHandler.thisUser;
    
    firstZoom = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (locationHandler.isAuthorized) {
        [self zoomToCurrentLocation];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    mainWindow = [[UIApplication sharedApplication] keyWindow];
    collectionViewCenter = [mainWindow convertPoint:self.collectionView.center fromWindow:nil];
}

#pragma mark - Map
// TODO: only zoom to location the first time
// TODO: search bar
- (IBAction)showUserLocation:(id)sender {
    [self zoomToCurrentLocation];
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationHandler.currentLocation.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
    
    // TODO: remove redundant calls to getSpots as a result of multiple zooms
    [self getSpotsInRegion:viewRegion];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // update which map marker is selected
    [self highlightMarkerForCenteredCell];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
//    NSLog(@"view for annotation");
    // If it's the user location, just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKAnnotationCustom class]])
    {
        // Try to dequeue an existing annotation view first
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"reuseAnnotationView"];
        
        if (!annotationView)
        {
            // If an existing pin view was not available, create one.
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"reuseAnnotationView"];
            annotationView.canShowCallout = NO;
            
            // set pin image
            UIImage *pinImage = [UIImage imageNamed:@"pinImage.png"];
            annotationView.image = pinImage;
            
            annotationView.centerOffset = CGPointMake(0.0, -32.0);
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        [self.annotationViews addObject:annotationView];
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *av = [mapView viewForAnnotation:mapView.userLocation];
    av.enabled = NO;  //disable touch on user location
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView*)view {
    // deselect all others first
//    for (Spot *spot in self.nearbySpots) {
//        MKAnnotationCustom *annotation = [spot getAnnotation];
//        [self.mapView deselectAnnotation:annotation animated:YES];
//    }
    for (MKAnnotationView *aView in self.annotationViews) {
        [self mapView:self.mapView didDeselectAnnotationView:aView];
    }
    
    UIImage *pinSelectedImage = [UIImage imageNamed:@"pinSelectedImage.png"];
    view.image = pinSelectedImage;
    
    // TODO: center appropriate cell in collectionView
        
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView*)view {
    UIImage *pinImage = [UIImage imageNamed:@"pinImage.png"];
    view.image = pinImage;
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.nearbySpots count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell %i",(int)indexPath.row);
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
    if (!cell) {
        // TODO: error handling
    }
    // fetch photo and update display of cell
    [cell displayInfoForSpot:self.nearbySpots[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // center the cell
    int index = (int)indexPath.row;
    NSLog(@"selected cell %i",index);
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    // select the associated marker on the map
//    MKAnnotationView *annotationView = self.annotationViews[index];
//    [self highlightAnnotationViewOnMap:annotationView];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int height = collectionView.frame.size.height;
    cellWidth = height;

    return CGSizeMake(height, height); // create square cells at maximum height of CollectionView
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    int offset = (collectionView.frame.size.width - cellWidth)/2;
    return UIEdgeInsetsMake(0, offset, 0, offset); // !!!
}

-(void)highlightMarkerForCenteredCell {
    // get the index of the collectionView cell currently at the center of the screen
    CGPoint pointInViewCoords = [self.collectionView convertPoint:collectionViewCenter fromView:mainWindow];
//    NSLog(@"(%i, %i)",(int)pointInViewCoords.x,(int)pointInViewCoords.y);
    NSIndexPath *centeredIndexPath = [self.collectionView indexPathForItemAtPoint:pointInViewCoords];
    PhotoCollectionViewCell *centeredCell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:centeredIndexPath];
    
    MKAnnotationCustom *annotation = [centeredCell.spot getAnnotation];
    [self.mapView selectAnnotation:annotation animated:YES];

//    MKAnnotationView *highlightMarker = self.annotationViews[(int)centeredIndexPath.row];
//    [self highlightAnnotationViewOnMap:highlightMarker];
}

#pragma mark - AnnotationViews
-(void)placeSpotMarker:(MKAnnotationCustom*)marker {
    [self.mapView addAnnotation:marker];
}

// removes all previous markers
// TODO: for smoother transition just remove markers whose id's aren't in updated spots list
-(void)removeSpotMarkers {
    for (id<MKAnnotation> annotation in self.mapView.annotations)
    {
        [self.annotationViews removeAllObjects];
        [self.mapView removeAnnotation:annotation];
    }
}

//-(void)highlightAnnotationViewOnMap:(MKAnnotationView*)annotationView {
//    [self mapView:self.mapView didSelectAnnotationView:annotationView];
//}

#pragma mark - Spots

// allows user to actively refresh visible spots
- (IBAction)refreshSpots:(id)sender {
    [self getSpotsInView];
}

-(void)getSpotsInView {
    [self getSpotsInRegion:self.mapView.region];
}

-(void)getSpotsInRegion:(MKCoordinateRegion)region {
    // TODO: how to handle offline use

    [self.nearbySpots removeAllObjects];

    // start the activity indicator
    [self.activityIndicator startAnimating];
    self.noSpotsText.hidden = YES;
    
    [serverHandler queryRegion:region handleResponse:^void (NSDictionary *spots) {
        // force to main thread for UI updates
        dispatch_async(dispatch_get_main_queue(), ^(void){
            for (NSDictionary *serverSpot in spots) {
                // see if Spot object already exists in Core Data
                Spot *nextSpot;
                NSString *databaseId = serverSpot[@"_id"];
                
                nextSpot = (Spot*)[coreDataHandler getObjectWithDatabaseId:databaseId];
                
                // if Spot object doesn't already exist in Core Data, create it
                if (!nextSpot) {
                    // NSLog(@"new");
                    nextSpot = (Spot*)[coreDataHandler createNew:@"Spot"];
                }
                //            NSLog(@"    spot object");
                // update Spot from server info and then add to array
                [nextSpot updateFromDictionary:serverSpot];
                [self.nearbySpots addObject:nextSpot];
            }
            // stop the activity indicator - hides automatically
            [self.activityIndicator stopAnimating];
            
            [self.collectionView reloadData]; // populates scrollable photo previews
            
            // remove all markers
            [self removeSpotMarkers];
            
            if (self.nearbySpots.count > 0) {
                self.noSpotsText.hidden = YES;
                // TODO: should spot markers be children of the cells? Of the spots?
                [self placeSpotMarkers];
            } else {
                self.noSpotsText.hidden = NO;
            }
        });
    }];
}

// populates the map with pins at each Spot location
-(void)placeSpotMarkers {
        for (Spot *spot in self.nearbySpots) {
    //        MKPointAnnotation *spotMarker = [[MKPointAnnotation alloc] init];
    //        spotMarker.coordinate = [spot getCoordinate];
    //        [self.mapView addAnnotation:spotMarker];
            
            // returns annotation and also makes sure one is created in spot property
            MKAnnotationCustom *spotMarker = [spot getAnnotation];

            [self placeSpotMarker:spotMarker];
            }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CreateSpot"]) {
        CreateSpotViewController *createSpotViewController = [segue destinationViewController];
        createSpotViewController.thisUser = self.thisUser;
    }
}

- (IBAction)createSpotButton:(id)sender {
    // check for permissions first - user must be logged in
    BOOL loggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedIn"];
    if (loggedIn) {
        [self performSegueWithIdentifier:@"CreateSpot" sender:self];
    } else {
        // warning message that user must sign in first
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Member Feature"
                                                        message:@"You must be signed in to add new spots. Please visit the profile page and log in first."
                                                       delegate:self
                                              cancelButtonTitle:@"Okay!"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)spotDoubleTap:(UITapGestureRecognizer *)sender {
    CGPoint tapLocation = [sender locationInView:self.collectionView];
    NSIndexPath *tappedIndexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    PhotoCollectionViewCell *tappedCell = (PhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:tappedIndexPath];

    [self viewSpotDetails:tappedCell.spot];
}

-(void)viewSpotDetails:(Spot*)spot {
    // TODO: implement detail view
    NSLog(@"view spot %@",spot.databaseId);
    
}

-(IBAction)unwindToMapView:(UIStoryboardSegue*)unwindSegue {
    NSLog(@"unwinding to MapView");
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
