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

@implementation Photo (Extended)

-(void)updateFromDictionary:(NSDictionary*)dictionary{
    if (self) {
        self.databaseId = dictionary[@"_id"];
        self.creationTimestamp = dictionary[@"creationTimestamp"];
        self.latitude = dictionary[@"latitude"];
        self.longitude = dictionary[@"longitude"];
        self.localPath = dictionary[@"localPath"];
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
        // in case the photo gets saved to the server before the spot does
        jsonable[@"photoSpot"] = self.photoSpot.databaseId; // only one
    }
    
    return jsonable;
}


 // TODO: re-implement using fetching from local or online path
-(UIImage*)getImage {
    UIImage *image;
    NSLog(@"checking for local image");
    if (self.localPath && ![self.localPath isEqualToString:@"NA"]) {
        // if localPath has been set and is valid, load image
        // set image to return variable
        image = [UIImage imageWithContentsOfFile:self.localPath];
    }
    // if image is still nil and there's a valid online path
    if (!image && self.onlinePath && ![self.onlinePath isEqualToString:@"NA"]) {
        NSLog(@"checking for online image");
        // if onlinePath has been set and is valid, load image
        NSData *recievedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.onlinePath]];
        // save image to a local URL
        // add local URL to localPath
        // set image to return variable
        image =[UIImage imageWithData:recievedData];
    }
    return image;
}

-(void)saveImageToLocalCache:(UIImage*)image {
    // save photo to local cache and save path to photo.localPath
    NSData *saveImage = UIImageJPEGRepresentation(image,1.0);
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // TODO: want this to be Photo's databaseId, temp using random number
    NSString *randomFileName = [NSString stringWithFormat:@"photo%i", arc4random_uniform(9999)];
    NSString *file = [cachesFolder stringByAppendingPathComponent:randomFileName];
    self.localPath = file;
    [saveImage writeToFile:file options:NSDataWritingAtomic error:nil];
}

@end
