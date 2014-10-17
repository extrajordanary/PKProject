//
//  Photo+Extended.h
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Photo.h"
#import <UIKit/UIKit.h>

@interface Photo (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)toDictionary;
//-(UIImage*)getImage;

@end
