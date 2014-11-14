//
//  MKAnnotationCustom.m
//  PKProject
//
//  Created by Jordan on 11/13/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "MKAnnotationCustom.h"

@implementation MKAnnotationCustom

@synthesize coordinate;// = _coordinate;
@synthesize title;// = _title;
@synthesize subtitle;// = _subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
    
    if (self != nil) {
//        self.coordinate = coord;
        [self setCoordinate:coord];
    }
    
    return self;
}

@end
