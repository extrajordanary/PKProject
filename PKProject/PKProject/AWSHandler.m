//
//  AWSHandler.m
//  PKProject
//
//  Created by Jordan on 10/31/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "AWSHandler.h"

@implementation AWSHandler

#pragma mark - Singleton Methods
+(id) sharedAWSHandler {
    static AWSHandler *sharedAWSHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAWSHandler = [[self alloc] init];
    });
    return sharedAWSHandler;
}



@end
