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

//@property (nonatomic, retain) UIImage *image;

-(void)updateFromDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)toDictionary;

@end
