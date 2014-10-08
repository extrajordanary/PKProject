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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    theContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    databaseHandler = [DatabaseHandler sharedDatabaseHandler];
    
    // create new Spot and Photo objects
    newSpot = [NSEntityDescription insertNewObjectForEntityForName:@"Spot" inManagedObjectContext:theContext];
    newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:theContext];

}

-(void)viewWillDisappear:(BOOL)animated {
    // assign final values to both spot and photo
    newSpot.creationTimestamp = [NSDate date];
    newPhoto.creationTimestamp = [NSDate date];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
