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
        // some set up
    }
    return self;
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
//        error message?
        return; //input safety check
    }
    NSString* spots = [kBaseURL stringByAppendingPathComponent:kSpots];
    
    BOOL isExistingSpot = spot.databaseId != nil;
    NSURL* url = isExistingSpot ? [NSURL URLWithString:[spots stringByAppendingPathComponent:spot.databaseId]] :
    [NSURL URLWithString:spots];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = isExistingSpot ? @"PUT" : @"POST";
    
    // get converted Spot for uploading to server
    NSData* data = [NSJSONSerialization dataWithJSONObject:[spot toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            // get _id from returned data and save it to the Spot databaseId property
            spot.databaseId = responseArray[0][0][@"_id"];
        }
    }];
    [dataTask resume];
}

#pragma mark - Photos

@end
