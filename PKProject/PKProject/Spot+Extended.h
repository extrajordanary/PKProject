//
//  Spot+Extended.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Spot.h"

@interface Spot (Extended)

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

-(void)updateFromDictionary:(NSDictionary*)dictionary;

-(NSDictionary*)toDictionary;

@end
