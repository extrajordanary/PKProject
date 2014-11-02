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
        
        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                              credentialsProvider:credentialsProvider];
        
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
//        s3TransferManager = [[AWSS3TransferManager new] initWithConfiguration:configuration identifier:@"cvalt"];
        s3TransferManager = [AWSS3TransferManager defaultS3TransferManager];
        
//        AWSCognito *syncClient = [AWSCognito defaultCognito];
//        AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"myDataset"];
//        [dataset setString:@"myValue" forKey:@"myKey"];
//        [dataset synchronize];
    }
    return self;
}

-(void)uploadImageFromURL:(NSURL*)imageUrl withName:(NSString*)name {
    NSLog(@"uploading to S3");
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"cvalt-photos";
    uploadRequest.key = name;
//    NSURL *url = [NSURL URLWithString:imageUrl];
    uploadRequest.body = imageUrl;
    
    [s3TransferManager upload:uploadRequest];
}


//- (BFTask *)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest

//S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:my_key inBucket: my_bucket_name];
//[putObjectRequest setFilename:videoMetaData.videoFilePath];
//
//[putObjectRequest addMetadataWithValue:[UserSessionInfo sharedSessionInfo].userEmail forKey:@"email"];
//[putObjectRequest addMetadataWithValue:[UtilHelper formatDuration:videoMetaData.length] forKey:@"videolength"];
//[putObjectRequest addMetadataWithValue:@"Landscape" forKey:@"orientation"];
//[putObjectRequest addMetadataWithValue:[NSString stringWithFormat:@"%d", data.length] forKey:@"size"];
//
//putObjectRequest.contentType = @"video/quicktime";
//self.uploadFileOperation = [self.s3TransferManager upload:putObjectRequest];



//AmazonS3Client *s3Client = [[AmazonS3Client alloc] initWithAccessKey:@"Key_Goes_here" withSecretKey:@"Secret_Goes_Here"];
//
//NSString *imageName = [NSString stringWithFormat:@"%@.png", @"cpa"];
//
//S3PutObjectRequest *objReq = [[S3PutObjectRequest alloc] initWithKey:imageName inBucket:@"bucket_name"];
//objReq.contentType = @"image/png";
//objReq.cannedACL   = [S3CannedACL publicRead];
//objReq.data = UIImagePNGRepresentation(myFace);
//objReq.delegate = self;
//
//[s3Client putObject:objReq];
@end
