//
//  User+AdditionalMethods.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "User+AdditionalMethods.h"

@implementation User (AdditionalMethods)

-(NSString *)lastNameFirstNameString {
    return [NSString stringWithFormat:@"%@, %@", self.nameLast, self.nameFirst];
}

@end
