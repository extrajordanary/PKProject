//
//  AWSHandler.h
//  PKProject
//
//  Created by Jordan on 10/31/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSiOSSDKv2/AWSS3.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSS3TransferManager.h>

@interface AWSHandler : NSObject //<AmazonServiceRequestDelegate>

+(id) sharedAWSHandler;
-(void)uploadImageFromFile:(NSString*)fullImagePath withName:(NSString*)name;

@end
