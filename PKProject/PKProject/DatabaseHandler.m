//
//  DatabaseHandler.m
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "DatabaseHandler.h"
#import "User+Extended.h"

// This class is responsible for handling calls to the database
// and converting the results into a JSON object to pass to the other classes

static NSString* const kBaseURL = @"http://travalt.herokuapp.com";
static NSString* const kUsers = @"/collections/users"; 
static NSString* const kSpots = @"/collections/spots";
static NSString* const kPhotos = @"/collections/photos";

@implementation DatabaseHandler

#pragma mark - Singleton Methods

+ (id)sharedDatabaseHandler {
    static DatabaseHandler *sharedDatabaseHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabaseHandler = [[self alloc] init];
    });
    return sharedDatabaseHandler;
}

- (id)init {
    if (self = [super init]) {
        // some set up
    }
    return self;
}

#pragma mark - Users

#pragma message "This fetches the information about a user from the server and updates the local information, correct? Maybe the method should be renamed (mentioning 'server' instead of 'database') and you could add one or two comments to make this more obvious"

- (void)updateUserFromDatabase:(User*)user {
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

#pragma mark - Photos

@end
