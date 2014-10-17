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
#import "Spot+Extended.h"
#import "User+Extended.h"
#import "Photo.h"

@interface CreateSpotViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *spotImage;
//@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation CreateSpotViewController {
    Spot *newSpot;
    Photo *newPhoto;
    NSManagedObjectContext *theContext;
    ServerHandler *serverHandler;
    MKPointAnnotation *spotMarker;
}

static const CGFloat kMetersPerMile = 1609.344;
static const CGFloat kDefaultZoomMiles = 0.2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    theContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    serverHandler = [ServerHandler sharedServerHandler];
    spotMarker = [[MKPointAnnotation alloc] init];
//    [self startStandardMapUpdates];
    
    self.locationManager.delegate = self;
    [self zoomToCurrentLocation];
    
    // create new Spot and Photo objects
    newSpot = [NSEntityDescription insertNewObjectForEntityForName:@"Spot" inManagedObjectContext:theContext];
    newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:theContext];

    self.spotImage.image = [UIImage imageNamed:@"defaultSpotPhoto.jpg"];
    [self.spotImage setClipsToBounds:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    spotMarker.coordinate = self.locationManager.location.coordinate;
    [self.mapView addAnnotation:spotMarker];
}

/*
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

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
        [self zoomToCurrentLocation];
    }
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

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
    
    // assign photo to Photo and add timestamp
    NSData *imageData = UIImagePNGRepresentation(image);
    newPhoto.imageBinary = imageData;
    
    NSManagedObjectContext *context = theContext;
    NSError *error = nil;
    [context save:&error];
    if (error) {
        // TODO: error handling
    }
}

#pragma mark - Data
-(void)saveNewSpot {
    // assign final values to both spot and photo
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
    
    [newSpot setSpotByUser:self.thisUser];
    [newPhoto setPhotoByUser:self.thisUser];
    [newSpot addSpotPhotosObject:newPhoto];
    
    // save Spot to server
    // get Spot's new ObjectId
    // add Spot OID to Photo
    // save photo
    // get photo OID
    // update Spot with Photo OID
    
    // TODO: hotfix to test photo OID
//    newPhoto.databaseId = @"54384a22d973a634c2001cce";
    
    [serverHandler pushSpotToServer:newSpot];
//    [serverHandler pushPhotoToServer:newPhoto];
    
    // save Photo to server - should be done
    
    // update User info on server
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
