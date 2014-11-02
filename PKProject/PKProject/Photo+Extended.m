//
//  Photo+Extended.m
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "Photo+Extended.h"
#import "Spot+Extended.h"
#import "User+Extended.h"
#import "ServerObject+Extended.h"
#import "ServerHandler.h"
#import "AWSHandler.h"

static NSString* const kAWSBase = @"https://s3-us-west-1.amazonaws.com/cvalt-photos/";

@implementation Photo (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary{
    if (self) {
        self.databaseId = dictionary[@"_id"];
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.latitude = dictionary[@"latitude"];
        self.longitude = dictionary[@"longitude"];
        self.localPath = dictionary[@"localPath"]; // check if the new one is NA before overwriting local data
        self.onlinePath = dictionary[@"onlinePath"];
        // TODO: photoByUser - but I don't need to create these objects every time.
        // TODO: photoSpot
        
        [self updateCoreData];
    }
}

-(NSDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    jsonable[@"creationTimestamp"] = self.creationTimestamp;
    jsonable[@"latitude"] = self.latitude;
    jsonable[@"longitude"] = self.longitude;
    jsonable[@"localPath"] = self.localPath;
    jsonable[@"onlinePath"] = self.onlinePath;
    
    jsonable[@"photoByUser"] = self.photoByUser.databaseId; // only one
    
    if (self.photoSpot.databaseId) {
        // just in case the photo gets saved to the server before the spot does
        jsonable[@"photoSpot"] = self.photoSpot.databaseId; // only one
    }
    
    return jsonable;
}

-(UIImage*)getImage {
    UIImage *image;
    NSLog(@"checking for local image");
    // TODO: what to do when Photo doesn't have databaseId when image is requested?
    if (self.databaseId && ![self.databaseId isEqualToString:@"0"]) {
        // check if an image has been saved to the local cache
        image = [UIImage imageWithContentsOfFile:[self getLocalPath]];
        
        // if image is still nil, download the image from online
        if (!image) {
            NSString *onlinePath = [[kAWSBase stringByAppendingString:self.databaseId] stringByAppendingString:@".jpg"];
            NSLog(@"checking for online image: %@",onlinePath);
            NSData *recievedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:onlinePath]];
            // set image to return variable
            image =[UIImage imageWithData:recievedData];
            if (image) {
                NSLog(@"saving locally");
                // for quicker retrieval next time
                [self saveImageToLocalCache:image];
            }
        }
    } else { // must still be using temp image
        NSLog(@"Using temp photo path");
//        NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        // TODO: use different temp file naming method
//        NSString *lat = [NSString stringWithFormat:@"%i",(int)self.latitude];
//        NSString *localPath = [[cachesFolder stringByAppendingString:lat] stringByAppendingString:@".jpg"]; // TODO: reduce redundancy
        
        image = [UIImage imageWithContentsOfFile:[self getTempLocalPath]];
    }
    
    return image;
}

-(void)saveImageToLocalCache:(UIImage*)image {
    NSData *saveImage = UIImageJPEGRepresentation(image,1.0);

//    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localPath;
    if (self.databaseId) {
//        localPath = [[cachesFolder stringByAppendingPathComponent:self.databaseId] stringByAppendingString:@".jpg"];
        localPath = [self getLocalPath];
        NSLog(@"saving to final");
    } else {
        // if Photo hasn't gotten a permanent databaseId yet, save to a temp location
//        NSString *lat = [NSString stringWithFormat:@"%i",(int)self.latitude];
//        localPath = [[cachesFolder stringByAppendingString:lat] stringByAppendingString:@".jpg"];
        localPath = [self getTempLocalPath];
        NSLog(@"saving to temp");
    }
    
    [saveImage writeToFile:localPath options:NSDataWritingAtomic error:nil];
}

-(void)receivedDatabaseId {
    // called from callback when photo has been saved to the server
    // get the image saved in the temp location
    NSLog(@"databaseId recieved");

//    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *lat = [NSString stringWithFormat:@"%i",(int)self.latitude];
//    NSString *localPath = [[cachesFolder stringByAppendingString:lat] stringByAppendingString:@".jpg"];
    NSString *localPath = [self getTempLocalPath];
    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
    
    // should now save to the correct path using database Id
    [self saveImageToLocalCache:image];
    [self saveImageToAWS:localPath];
    
    // TODO: delete old temp file in local cache
    
}

-(void)saveImageToAWS:(NSString*)imagePath {
    NSLog(@"sending to AWSHandler");
    AWSHandler *aws = [AWSHandler sharedAWSHandler];
    NSString *fixedString = [NSString stringWithFormat:@"file:///%@",imagePath];
    NSURL *imageUrl = [NSURL URLWithString:fixedString];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",self.databaseId];
    [aws uploadImageFromURL:imageUrl withName:imageName];
}

-(NSString*)getTempLocalPath {
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *lat = [NSString stringWithFormat:@"%i",(int)([self.latitude floatValue]*10000)];
//    NSString *temp = @"temp";
    NSString *localPath = [[cachesFolder stringByAppendingPathComponent:lat] stringByAppendingString:@".jpg"];
    NSLog(@"%@",localPath);
    return localPath;
}

-(NSString*)getLocalPath {
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localPath = [[cachesFolder stringByAppendingPathComponent:self.databaseId] stringByAppendingString:@".jpg"];
    NSLog(@"%@",localPath);
    return localPath;
}

@end
