//
//  CreateSpotViewController.m
//  PKProject
//
//  Created by Jordan on 10/7/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "CreateSpotViewController.h"
#import "AppDelegate.h"

#import "ServerHandler.h"
#import "CoreDataHandler.h"
#import "Spot+Extended.h"
#import "User+Extended.h"
#import "Photo.h"

@interface CreateSpotViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *spotImage;

@end

@implementation CreateSpotViewController {
    Spot *newSpot;
    Photo *newPhoto;
    ServerHandler *serverHandler;
    CoreDataHandler *coreDataHandler;
    MKPointAnnotation *spotMarker;
}

static const CGFloat kMetersPerMile = 1609.344;
static const CGFloat kDefaultZoomMiles = 0.2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    serverHandler = [ServerHandler sharedServerHandler];
    coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    spotMarker = [[MKPointAnnotation alloc] init];
    
    self.locationManager.delegate = self;
    [self zoomToCurrentLocation];
    
    // create new Spot and Photo objects
    newSpot = [coreDataHandler newSpot];
    newPhoto = [coreDataHandler newPhoto];

    self.spotImage.image = [UIImage imageNamed:@"defaultSpotPhoto.jpg"];
    [self.spotImage setClipsToBounds:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    spotMarker.coordinate = self.locationManager.location.coordinate;
    [self.mapView addAnnotation:spotMarker];
}

#pragma mark - Location Manager
// ??? - is this even being used?
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

// ??? - is this even being used?
// delegate method called when user changes authorization to allow location tracking
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status) {
        [self zoomToCurrentLocation];
    }
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

// ??? - is this even being used?
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];

    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
}

#pragma mark - Image Picker
- (IBAction)changePicture:(id)sender {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;

    // TODO: always give user the option to choose instead of assuming one or the other
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePicker animated:YES completion:^{
        //
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissModalViewControllerAnimated:YES];
    
    // set current view controller image
    self.spotImage.image = image;
    
    // assign photo to Photo
    // TODO: save the image locally and online and update properties

    [coreDataHandler updateCoreData];
}

#pragma mark - Data
-(void)saveNewSpot {
    // assign final values to both spot and photo
    // TODO: move dateFormatter into a getTimestamp method in ServerObject class
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    NSDate *date = [NSDate date];
    newSpot.creationTimestamp = [dateFormatter stringFromDate:date];
    newPhoto.creationTimestamp = [dateFormatter stringFromDate:date];
    
    newSpot.latitude = [NSNumber numberWithDouble:spotMarker.coordinate.latitude];
    newSpot.longitude = [NSNumber numberWithDouble:spotMarker.coordinate.longitude];
    newPhoto.latitude = [NSNumber numberWithDouble:spotMarker.coordinate.latitude];
    newPhoto.longitude = [NSNumber numberWithDouble:spotMarker.coordinate.longitude];
    
    // !!! - AWS testing only
    newPhoto.onlinePath = @"https://s3-us-west-1.amazonaws.com/travalt-photos/defaultSpotPhoto.jpg";
    
    [newSpot setSpotByUser:self.thisUser];
    [newPhoto setPhotoByUser:self.thisUser];
    [newSpot addSpotPhotosObject:newPhoto];

    // completion block then saves the photo to the server, then updates spot and user again
    // TODO: should serverHandler have a special createNewSpot:(Spot*)spot withPhoto:(Photo*)photo method? Probably
    [serverHandler pushSpotToServer:newSpot];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"Cancel"]) {
        //
    }
    else if ([segue.identifier isEqualToString:@"Save"]) {
        [self saveNewSpot];
    }
}


@end
