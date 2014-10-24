//
//  ServerHandler.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "ServerHandler.h"
#import "User+Extended.h"
#import "Spot+Extended.h"
#import "Photo+Extended.h"

// This class is responsible for handling all calls to the server

static NSString* const kBaseURL = @"http://travalt.herokuapp.com";
static NSString* const kUsers = @"/collections/users"; 
static NSString* const kSpots = @"/collections/spots";
static NSString* const kPhotos = @"/collections/photos";

@implementation ServerHandler

#pragma mark - Singleton Methods
+ (id)sharedServerHandler {
    static ServerHandler *sharedServerHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServerHandler = [[self alloc] init];
    });
    return sharedServerHandler;
}

- (id)init {
    if (self = [super init]) {
        // ??? - Anything to include here?
    }
    return self;
}

-(void)updateObjectFromServer:(ServerObject*)object {
    // see what the object type is, then pass it to the appropriate method
    NSLog(@"object fake updated from server");
}

#pragma mark - Users
// given a User object, method pulls updated User info from server and updates object properties
- (void)updateUserFromServer:(User*)user {
    NSString* userId = user.databaseId;
    NSString* requestURL = [NSString stringWithFormat:@"%@%@/%@",kBaseURL,kUsers,userId];
    NSURL* url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error == nil) {
                                                        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                                        [user updateFromDictionary:responseDictionary];
                                                    }
                                                }];
    
    [dataTask resume];
}

#pragma mark - Spots
// returns all Spots from server and passes them to a block which will parse the info in the desired fashion
// TODO: update method to take query parameters
-(void)getSpotsFromServer:(void (^)(NSDictionary*))spotHandlingBlock {
    NSString* requestURL = [NSString stringWithFormat:@"%@%@",kBaseURL,kSpots];
    NSURL* url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error == nil) {
                                                        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                                        spotHandlingBlock(responseDictionary);
                                                    }
                                                }];
    
    [dataTask resume];
}

// given a Spot object, method checks if the Spot already exists on the server
// then it either creates a new entry in the server or updates the existing entry
-(void)pushSpotToServer:(Spot*)spot {
    if (!spot || spot.latitude == nil || spot.longitude == nil || spot.spotPhotos == nil) {
        // TODO: error?
        return; //input safety check
    }
    NSString* spots = [kBaseURL stringByAppendingPathComponent:kSpots];
    
    BOOL isExistingSpot = spot.databaseId != nil;
    NSURL* url = isExistingSpot ? [NSURL URLWithString:[spots stringByAppendingPathComponent:spot.databaseId]] :
    [NSURL URLWithString:spots];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = isExistingSpot ? @"PUT" : @"POST";
    
    // get JSON converted Spot for uploading to server
    NSData* data = [NSJSONSerialization dataWithJSONObject:[spot toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            if (isExistingSpot) {
                // do nothing bc response array just has success msg
            } else {
                // get _id from returned data and save it to the Spot databaseId property
                spot.databaseId = responseArray[0][0][@"_id"];
                [self pushPhotoToServer:spot.spotPhotos.allObjects[0]]; // !!! - only safe for NEW spots with no other photos
            }
        }
    }];
    [dataTask resume];
}

#pragma mark - Photos
// given a Photo object, method checks if the Photo already exists on the server
// then it either creates a new entry in the server or updates the existing entry
-(void)pushPhotoToServer:(Photo*)photo {
    if (!photo || photo.latitude == nil || photo.longitude == nil) { // || photo.imageBinary == nil) {
        // TODO: error?
        return; //input safety check
    }
    NSString* photos = [kBaseURL stringByAppendingPathComponent:kPhotos];
    
    BOOL isExistingPhoto = photo.databaseId != nil;
    NSURL* url = isExistingPhoto ? [NSURL URLWithString:[photos stringByAppendingPathComponent:photo.databaseId]] :
    [NSURL URLWithString:photos];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = isExistingPhoto ? @"PUT" : @"POST";
    
    // get converted Spot for uploading to server
    NSData* data = [NSJSONSerialization dataWithJSONObject:[photo toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            if (isExistingPhoto) {
                // do nothing bc response array just has success msg
            } else {
                // get _id from returned data and save it to the Photo databaseId property
                photo.databaseId = responseArray[0][0][@"_id"];
                // update Spot on server now that it can add the photo databaseId
                [self pushSpotToServer:photo.photoSpot];
                // TODO: update User to include new photo databaseId
            }
        }
    }];
    [dataTask resume];
}

@end
