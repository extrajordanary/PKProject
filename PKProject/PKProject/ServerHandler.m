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

#pragma mark - Photos

@end
