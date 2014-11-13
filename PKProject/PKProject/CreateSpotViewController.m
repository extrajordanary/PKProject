//
//  CreateSpotViewController.m
//  PKProject
//
//  Created by Jordan on 10/7/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "CreateSpotViewController.h"
#import "AppDelegate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MapViewController.h"

#import "ServerHandler.h"
#import "CoreDataHandler.h"
#import "Spot+Extended.h"
#import "User+Extended.h"
#import "Photo+Extended.h"
#import "LocationManagerHandler.h"

@interface CreateSpotViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *spotImage;
@property (strong, atomic) ALAssetsLibrary* library;

@end

@implementation CreateSpotViewController {
    Spot *newSpot;
    Photo *newPhoto;
    ServerHandler *serverHandler;
    CoreDataHandler *coreDataHandler;
    LocationManagerHandler *locationHandler;
    MKPointAnnotation *spotMarker;
    NSDictionary *imageInfo;
}

static const CGFloat kMetersPerMile = 1609.344;
static const CGFloat kDefaultZoomMiles = 0.2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    serverHandler = [ServerHandler sharedServerHandler];
    coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    locationHandler = [LocationManagerHandler sharedLocationManagerHandler];
    
    // listen for changes from location manager
    [locationHandler addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [locationHandler addObserver:self forKeyPath:@"isAuthorized" options:NSKeyValueObservingOptionNew context:nil];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
    
    spotMarker = [[MKPointAnnotation alloc] init];
    spotMarker.coordinate = locationHandler.currentLocation.coordinate;
    [self.mapView addAnnotation:spotMarker];
    
    // create new Spot and Photo objects
    newSpot = (Spot*)[coreDataHandler createNew:@"Spot"];
    newPhoto = (Photo*)[coreDataHandler createNew:@"Photo"];

    self.spotImage.image = [UIImage imageNamed:@"defaultSpotPhoto.jpg"];
    [self.spotImage setClipsToBounds:YES];
    
    self.library = [[ALAssetsLibrary alloc] init];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add A Spot"
                                                    message:@"Please use a photo that provides a good sense of the overall location. You'll be able to add more photos of objects and tricks later."
                                                   delegate:nil
                                          cancelButtonTitle:@"Got it!"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (locationHandler.isAuthorized) {
        [self zoomToMarker];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Map
-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationHandler.currentLocation.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

-(void)zoomToMarker {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(spotMarker.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

#pragma mark - Location Setting
- (IBAction)setLocation:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.mapView];
    // offset y value so that user can see the bottom of the marker to place it more accurately
    CGPoint adjustedPoint = CGPointMake(point.x, point.y - 15);
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:adjustedPoint toCoordinateFromView:self.mapView];
    
    spotMarker.coordinate = tapPoint;
}

-(void)locationFromPhoto:(CLLocation*)location {
    if (location) {
        NSLog(@"update marker location from photo");
        spotMarker.coordinate = location.coordinate;
        [self zoomToMarker];
    } else {
        // popup to let user know they need to set the location manually
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Photo Location"
                                                        message:@"Please set the spot location manually."
                                                       delegate:nil
                                              cancelButtonTitle:@"I won't forget!"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Image Picker
// from former button, not sure if I'll be using it in final UI
- (IBAction)pictureFromCamera:(id)sender {
    [self useCamera];
}

- (IBAction)tapUseCamera:(UITapGestureRecognizer *)sender {
    [self useCamera];
}

-(void)useCamera {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // TODO: still getting snapshotting warning message here
    [self presentViewController:imagePicker animated:YES completion:^{
        //
    }];
    
}

- (IBAction)selectChoosePhoto:(id)sender {
    [self pictureFromPhotoLibrary];
}

- (void)pictureFromPhotoLibrary {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        //
    }];
}

// from former button, not sure if I'll be using it in final UI
- (IBAction)pictureFromPhotoLibrary:(id)sender {
    [self pictureFromPhotoLibrary];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // set current view controller image
    self.spotImage.image = image;

    if ([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary) {
        // get the ALAsset to get the meta data to update the location

        // Get the asset url
        NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        
        // We need to use blocks. This block will handle the ALAsset that's returned:
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            // Get the location property from the asset
            CLLocation *location = [myasset valueForProperty:ALAssetPropertyLocation];
            [self locationFromPhoto:location];
        };
        // This block will handle errors:
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Can not get asset - %@",[myerror localizedDescription]);
            // Do something to handle the error
        };
        
        // Use the url to get the asset from ALAssetsLibrary,
        // the blocks that we just created will handle results
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:url
                       resultBlock:resultblock
                      failureBlock:failureblock];
        
    } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // Save new image to CVALT Album in their Photo Library
        [self.library saveImage:image toAlbum:@"CVALT" withCompletionBlock:^(NSError *error) {
            NSLog(@"Image saving");
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
        }];
    }

    [coreDataHandler updateCoreData];

    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Data
-(void)saveNewSpot {
    // assign final values to both spot and photo
    // TODO: move dateFormatter into a singleton class?
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSDate *date = [NSDate date];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    newSpot.creationTimestamp = formattedDate;
    newPhoto.creationTimestamp = formattedDate;
    
    newSpot.latitude = [NSNumber numberWithDouble:spotMarker.coordinate.latitude];
    newSpot.longitude = [NSNumber numberWithDouble:spotMarker.coordinate.longitude];
    newPhoto.latitude = [NSNumber numberWithDouble:spotMarker.coordinate.latitude];
    newPhoto.longitude = [NSNumber numberWithDouble:spotMarker.coordinate.longitude];
    
    // save photo to local cache
    [newPhoto saveImageToLocalCache:self.spotImage.image];
    
    newSpot.spotByUser = self.thisUser;
    newPhoto.photoByUser = self.thisUser;
    [newSpot addSpotPhotosObject:newPhoto];

    [coreDataHandler updateCoreData];
    
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

//        [self saveNewSpot];
    }
    self.library = nil;
}

- (IBAction)saveButton:(id)sender {
    // popup to confirm information before saving
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm New Spot"
                                                    message:@"Is all the information correct?"
                                                   delegate:self
                                          cancelButtonTitle:@"Not yet..."
                                          otherButtonTitles:@"All good!",nil];
    [alert show];
}

#pragma mark - Alert Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"alert dismissed with button %i", (int)buttonIndex);
    if ((int)buttonIndex == 1) {
//        [self performSegueWithIdentifier:@"Save" sender:alertView];
        [self saveNewSpot];
        [self performSegueWithIdentifier:@"BackToMap" sender:alertView];
    }
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

-(IBAction)unwindToCreateSpot:(UIStoryboardSegue*)unwindSegue {
    NSLog(@"unwinding to MapView");
}

@end
