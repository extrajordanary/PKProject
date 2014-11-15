//
//  Spot+Extended.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Spot.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MKAnnotationCustom;

@interface Spot (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)toDictionary;
-(UIImage*)getThumbnail;
-(CLLocationCoordinate2D)getCoordinate;
-(MKAnnotationCustom*)getAnnotation;

@end
