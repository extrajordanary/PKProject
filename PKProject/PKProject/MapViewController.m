//
//  MapViewController.m
//  PKProject
//
//  Created by Jordan on 9/30/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "MapViewController.h"
#import "User+Extended.h"

static NSString* const kBaseURL = @"http://travalt.herokuapp.com/collections/test/";

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mainMap;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

#define METERS_PER_MILE 1609.344
#define DEFAULT_ZOOM_MILES .5

@implementation MapViewController {
    NSString *myUserId;
    NSArray *myUserInfo;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self startStandardUpdates];
    
    self.mainMap.showsUserLocation = YES;
    self.mainMap.showsPointsOfInterest = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self getAndDisplayUserName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location Manager

- (BOOL)startStandardUpdates
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
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, DEFAULT_ZOOM_MILES*METERS_PER_MILE, DEFAULT_ZOOM_MILES*METERS_PER_MILE);
        [self.mainMap setRegion:viewRegion animated:YES];
    }
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

#pragma mark - Testing Database Interaction
- (void)getAndDisplayUserName {
    // find out my username from the server and display it on screen
    myUserId = @"542efcec4a1cef02006d1021"; //hard coded to Professor X

    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:myUserId]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error == nil) {
                                                        NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                                        myUserInfo = responseArray;
                                                    }
                                                }];
    
    [dataTask resume];

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
