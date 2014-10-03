//
//  User+Extended.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "User+Extended.h"

@implementation User (Extended)

-(NSString *)lastNameFirstNameString {
    return [NSString stringWithFormat:@"%@, %@", self.nameLast, self.nameFirst];
}

@end
