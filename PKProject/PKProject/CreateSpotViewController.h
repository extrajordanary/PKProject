//
//  CreateSpotViewController.h
//  PKProject
//
//  Created by Jordan on 10/7/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class User;

@interface CreateSpotViewController : UIViewController <UIImagePickerControllerDelegate,
                                                        UINavigationControllerDelegate,
                                                        MKMapViewDelegate,
                                                        CLLocationManagerDelegate>
@property User *thisUser;

@end
