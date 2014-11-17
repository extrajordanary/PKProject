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
#import "MKAnnotationCustom.h"

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
    CLLocationCoordinate2D spotCoordinate;
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
    
    self.thisUser = coreDataHandler.thisUser;
    
    // listen for changes from location manager
    [locationHandler addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [locationHandler addObserver:self forKeyPath:@"isAuthorized" options:NSKeyValueObservingOptionNew context:nil];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.delegate = self;
    
    spotCoordinate = locationHandler.currentLocation.coordinate;
    
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
    [self updateSpotCoordinate];
    [super viewWillDisappear:animated];
}

#pragma mark - Map
- (IBAction)myLocation:(id)sender {
    [self zoomToCurrentLocation];   
}

-(void)zoomToCurrentLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationHandler.currentLocation.coordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

-(void)zoomToMarker {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(spotCoordinate, kDefaultZoomMiles*kMetersPerMile, kDefaultZoomMiles*kMetersPerMile);
    [self.mapView setRegion:viewRegion animated:YES];
}

/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // TODO: don't be redundant with same call in mapView
    // If it's the user location, just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations
    if ([annotation isKindOfClass:[MKAnnotationCustom class]])
    {
        // Try to dequeue an existing annotation view first
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"reuseAnnotationView"];
        
        if (!annotationView)
        {
            // If an existing pin view was not available, create one.
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"reuseAnnotationView"];
            annotationView.canShowCallout = NO;
            // TODO: draggable not working
            [annotationView setUserInteractionEnabled:YES];
            [annotationView setDraggable:YES];
            annotationView.dragState = MKAnnotationViewDragStateEnding;
            
            // set pin image
            UIImage *pinImage = [UIImage imageNamed:@"pinImage.png"];
            annotationView.image = pinImage;
            
            annotationView.centerOffset = CGPointMake(0.0, -32.0);
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}
*/

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
//    if ([view.annotation isKindOfClass:[MKAnnotationCustom class]]) {
//        if (newState == MKAnnotationViewDragStateEnding) {
//            view.dragState = MKAnnotationViewDragStateNone;
//        }
//    }
//}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *av = [mapView viewForAnnotation:mapView.userLocation];
    av.enabled = NO;  //disable touch on user location
}

#pragma mark - Location Setting
-(void)updateSpotCoordinate {
    spotCoordinate = CLLocationCoordinate2DMake(self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
}

-(void)locationFromPhoto:(CLLocation*)location {
    if (location) {
        NSLog(@"update marker location from photo");
        spotCoordinate = location.coordinate;
        [self zoomToMarker];
    } else {
        // popup to let user know they need to set the location manually
        [self noPhotoLocationAlert];
    }
}

#pragma mark - Image Picker
- (IBAction)tapUseCamera:(UITapGestureRecognizer *)sender {
    [self useCamera];
}

- (IBAction)cameraButton:(id)sender {
    [self useCamera];
}

- (IBAction)folderButton:(id)sender {
    [self pictureFromPhotoLibrary];
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
    
    // get the ALAsset to try to get the meta data to update the location
    if ([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary) {
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
            [self noPhotoLocationAlert];
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    // filename safe date format
    [dateFormatter setDateFormat:@"yyyy-MMM-dd_HH-mm-ss_zzz"];
    NSDate *date = [NSDate date];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    newSpot.creationTimestamp = formattedDate;
    newPhoto.creationTimestamp = formattedDate;

    [self updateSpotCoordinate];
    newSpot.latitude = [NSNumber numberWithDouble:spotCoordinate.latitude];
    newSpot.longitude = [NSNumber numberWithDouble:spotCoordinate.longitude];
    newPhoto.latitude = [NSNumber numberWithDouble:spotCoordinate.latitude];
    newPhoto.longitude = [NSNumber numberWithDouble:spotCoordinate.longitude];
    
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
//    if ([segue.identifier isEqualToString:@"Cancel"]) {
//        //
//    }
//    else if ([segue.identifier isEqualToString:@"Save"]) {
//        //
//    }
    self.library = nil;
}

- (IBAction)saveButton:(id)sender {
    // popup to confirm information before saving
    [self confirmSaveAlert];
}

#pragma mark - Alerts
-(void)confirmSaveAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm New Spot"
                                                    message:@"Is all the information correct?"
                                                   delegate:self
                                          cancelButtonTitle:@"Not yet..."
                                          otherButtonTitles:@"All good!",nil];
    [alert show];
}

-(void)noPhotoLocationAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Photo Location"
                                                    message:@"Please set the spot location manually by dragging the map."
                                                   delegate:nil
                                          cancelButtonTitle:@"I won't forget!"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"alert dismissed with button %i", (int)buttonIndex);
    if ((int)buttonIndex == 1) {
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

@end
