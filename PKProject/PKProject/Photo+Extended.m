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
        NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

        NSString *localPath = [[cachesFolder stringByAppendingPathComponent:self.databaseId] stringByAppendingString:@".jpg"];
        // set image to return variable
        image = [UIImage imageWithContentsOfFile:localPath];
        
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
        NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *localPath = [cachesFolder stringByAppendingString:self.creationTimestamp];
        image = [UIImage imageWithContentsOfFile:localPath];
    }
    
    return image;
}

-(void)saveImageToLocalCache:(UIImage*)image {
    NSData *saveImage = UIImageJPEGRepresentation(image,1.0);

    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localPath;
    if (self.databaseId) {
        localPath = [[cachesFolder stringByAppendingPathComponent:self.databaseId] stringByAppendingString:@".jpg"];
    } else {
        // if Photo hasn't gotten a permanent databaseId yet, save to a temp location
        localPath = [cachesFolder stringByAppendingString:self.creationTimestamp];
    }
    
    [saveImage writeToFile:localPath options:NSDataWritingAtomic error:nil];
}

-(void)receivedDatabaseId {
    // called from callback when photo has been saved to the server
    // get the image saved in the temp location
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localPath = [cachesFolder stringByAppendingString:self.creationTimestamp];
    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
    
    // should now save to the correct path using database Id
    [self saveImageToLocalCache:image];
    [self saveImageToAWS:image];
    
    // TODO: delete old temp file in local cache
    
}

-(void)saveImageToAWS:(UIImage*)image {
    NSLog(@"fake saving to AWS");
}

@end
