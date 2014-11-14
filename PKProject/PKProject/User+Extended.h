//
//  User+Extended.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "User.h"

@interface User (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary;
-(void)updateFromFacebookDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)toDictionary;

@end
