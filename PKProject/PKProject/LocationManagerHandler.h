//
//  LocationManagerHandler.h
//  PKProject
//
//  Created by Jordan on 11/5/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManagerHandler : NSObject <CLLocationManagerDelegate>

+ (id)sharedLocationManagerHandler;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL isAuthorized;

- (void)startUpdatingLocation;

@end
