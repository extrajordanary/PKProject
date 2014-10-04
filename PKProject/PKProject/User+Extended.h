//
//  User+Extended.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "User.h"

@interface User (Extended)

-(NSString *)lastNameFirstNameString;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(void)updateFromDictionary:(NSDictionary*)dictionary;
@end
