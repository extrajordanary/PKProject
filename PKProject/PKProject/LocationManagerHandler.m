//
//  LocationManagerHandler.m
//  PKProject
//
//  Created by Jordan on 11/5/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "LocationManagerHandler.h"
#import <UIKit/UIKit.h>

@implementation LocationManagerHandler

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#pragma mark - Singleton Methods
+ (id)sharedLocationManagerHandler {
    static LocationManagerHandler *sharedLocationManagerHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManagerHandler = [[self alloc] init];
    });
    return sharedLocationManagerHandler;
}

- (id)init {
    if(self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 500; // meters
        self.locationManager.delegate = self;
        
        if(IS_OS_8_OR_LATER) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    return self;
}

- (void)startUpdatingLocation {
    NSLog(@"Starting location updates");
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location service failed with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray*)locations {
    CLLocation *location = [locations lastObject];
    NSLog(@"Latitude %+.6f, Longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
    self.currentLocation = location;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status) {
        NSLog(@"authorized");
        self.isAuthorized = YES;
    } else {
        self.isAuthorized = NO;
    }
}

@end
