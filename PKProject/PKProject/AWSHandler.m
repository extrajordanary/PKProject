//
//  AWSHandler.m
//  PKProject
//
//  Created by Jordan on 10/31/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "AWSHandler.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSCognitoSync/Cognito.h>

@interface AWSHandler ()

@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest1;

@end

@implementation AWSHandler {
    AWSS3TransferManager *s3TransferManager;
}

#pragma mark - Singleton Methods
+(id) sharedAWSHandler {
    static AWSHandler *sharedAWSHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAWSHandler = [[self alloc] init];
    });
    return sharedAWSHandler;
}

- (id)init {
    if (self = [super init]) {

        AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                              credentialsWithRegionType:AWSRegionUSEast1
                                                              accountId:@"698954936319"
                                                              identityPoolId:@"us-east-1:596bbed4-2038-4f90-bf38-fa8bcda3f69c"
                                                              unauthRoleArn:@"arn:aws:iam::698954936319:role/Cognito_CVALTUnauth_DefaultRole"
                                                              authRoleArn:@"arn:aws:iam::698954936319:role/Cognito_CVALTAuth_DefaultRole"];
        
        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1
                                                                              credentialsProvider:credentialsProvider];
        
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        s3TransferManager = [AWSS3TransferManager defaultS3TransferManager];
    }
    return self;
}

-(void)uploadImageFromURL:(NSURL*)imageUrl withName:(NSString*)name {
    NSLog(@"uploading to S3");
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"cvalt-photos";
    uploadRequest.key = name;
    uploadRequest.body = imageUrl;
    
    [[s3TransferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
               task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                NSLog(@"upload failed");
                // TODO: handle failure - key photo object so it can try again later? try once more?
            }
        } else {
            NSLog(@"upload succeeded");
        }
        return nil;
    }];
}

@end
