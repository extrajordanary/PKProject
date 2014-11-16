//
//  MKAnnotationCustom.m
//  PKProject
//
//  Created by Jordan on 11/13/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "MKAnnotationCustom.h"

@implementation MKAnnotationCustom

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
    
    if (self != nil) {
        [self setCoordinate:coord];
    }
    
    return self;
}

@end
