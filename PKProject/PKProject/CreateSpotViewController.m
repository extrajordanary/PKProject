//
//  CreateSpotViewController.m
//  PKProject
//
//  Created by Jordan on 10/7/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "CreateSpotViewController.h"
#import "AppDelegate.h"

#import "DatabaseHandler.h"
#import "Spot+Extended.h"
#import "Photo.h"

@interface CreateSpotViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *spotImage;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

#define METERS_PER_MILE 1609.344
#define DEFAULT_ZOOM_MILES .2

@implementation CreateSpotViewController {
    Spot *newSpot;
    Photo *newPhoto;
//    UIImage *spotImage;
    NSManagedObjectContext *theContext;
    DatabaseHandler *databaseHandler;
    MKPointAnnotation *spotMarker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    theContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    databaseHandler = [DatabaseHandler sharedDatabaseHandler];
    spotMarker = [[MKPointAnnotation alloc] init];
    [self startStandardMapUpdates];
    
    // create new Spot and Photo objects
    newSpot = [NSEntityDescription insertNewObjectForEntityForName:@"Spot" inManagedObjectContext:theContext];
    newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:theContext];

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
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, DEFAULT_ZOOM_MILES*METERS_PER_MILE, DEFAULT_ZOOM_MILES*METERS_PER_MILE);
//        [self.mapView setRegion:viewRegion animated:YES];
        [self zoomToCurrentLocation];
    }
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, DEFAULT_ZOOM_MILES*METERS_PER_MILE, DEFAULT_ZOOM_MILES*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
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

#pragma mark - Image Picker
- (IBAction)changePicture:(id)sender {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
# pragma mark -- TODO
    // TODO: always give user the option to choose instead of assuming one or the other
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissModalViewControllerAnimated:YES];
    
    // set current view controller image
    self.spotImage.image = image;
    
    // assign photo to Photo and add timestamp
    NSData *imageData = UIImagePNGRepresentation(image);
    newPhoto.image = imageData;
    
    NSManagedObjectContext *context = theContext;
    NSError *error = nil;
    [context save:&error];
    if (error) {
        // error handling
    }
}

#pragma mark - Data
-(void)saveNewSpot {
    // assign final values to both spot and photo
    newSpot.creationTimestamp = [NSDate date];
    newPhoto.creationTimestamp = [NSDate date];
    
    newSpot.latitude = [NSNumber numberWithDouble:spotMarker.coordinate.latitude];
    newSpot.longitude = [NSNumber numberWithDouble:spotMarker.coordinate.longitude];
    newPhoto.latitude = [NSNumber numberWithDouble:spotMarker.coordinate.latitude];
    newPhoto.longitude = [NSNumber numberWithDouble:spotMarker.coordinate.longitude];
    
//    [newSpot setSpotByUser:<#(User *)#>];
//    [newPhoto setPhotoByUser:<#(User *)#>];
    [newSpot addSpotPhotoObject:newPhoto];
    
    // save Spot to server
    // save Photo to server
    // update User info on server
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Cancel"]) {
        // transition to edit spot view
    }
    else if ([segue.identifier isEqualToString:@"Save"]) {
        [self saveNewSpot];
    }
}


@end
