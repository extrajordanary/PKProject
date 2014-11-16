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

static NSString* const kBaseURL = @"http://travalt.herokuapp.com"; //TODO: change name on heroku to cvalt
static NSString* const kUsers = @"/collections/users"; 
//static NSString* const kSpots = @"/collections/spots"; // for real spots
static NSString* const kSpots = @"/collections/devspots"; // - for testing
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

#pragma mark - Generalized Method Calls
-(void)updateObjectFromServer:(ServerObject*)object {
    // see what the object type is, then pass it to the appropriate method
    if (object.databaseId) {
        if ([object isKindOfClass:[User class]]) {
//            NSLog(@"USER updated from server");
            [self updateUserFromServer:(User*)object];
        } else if ([object isKindOfClass:[Photo class]]) {
//            NSLog(@"PHOTO updated from server");
            [self updatePhotoFromServer:(Photo*)object];
        } else {
            // TODO: spot method
            NSLog(@"object fake updated from server");
        }
    }
}

// TODO: same as above for pushObjectToServer:(ServerObject*)object

#pragma mark - Users
// given a User object, method pulls updated User info from server and updates core data properties
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
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [user updateFromDictionary:responseDictionary];
            });
        }
    }];
    
    [dataTask resume];
}

// given a facebookId, check for existing User object on server and return it
- (void) queryFacebookId:(NSString*)facebookId handleResponse:(void (^)(NSArray*))responseHandlingBlock {
    NSString* facebookIdRequest = [NSString stringWithFormat:@"{\"facebookId\":{\"$in\":[\"%@\"]}}", facebookId];
    NSString* escBox = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                             (CFStringRef) facebookIdRequest,
                                                                                             NULL,
                                                                                             (CFStringRef) @"!*();':@&=+$,/?%#[]{}",
                                                                                             kCFStringEncodingUTF8));
    NSString* query = [NSString stringWithFormat:@"?query=%@", escBox];
    
    [self runFacebookIdQuery:query handleResponse:responseHandlingBlock];
}

- (void) runFacebookIdQuery:(NSString *)queryString handleResponse:(void (^)(NSArray*))responseHandlingBlock {
    NSString* urlStr = [[kBaseURL stringByAppendingPathComponent:kUsers] stringByAppendingString:queryString];
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSArray* responseArrray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            responseHandlingBlock(responseArrray);
            
            NSLog(@"%lu users found", (unsigned long)responseArrray.count);
        }
    }];
    [dataTask resume];
}

// given a User object, method checks if the User already exists on the server
// then it either creates a new entry in the server or updates the existing entry
// should only ever push THIS user
// TODO: ^ for now...?
-(void)pushUserToServer:(User*)user {
    if (!user) {
        // TODO: error?
        NSLog(@"Error saving user to server");
        return; //input safety check
    }
    NSString* users = [kBaseURL stringByAppendingPathComponent:kUsers];
    
    BOOL isExistingUser = user.databaseId != nil;
    NSURL* url = isExistingUser ? [NSURL URLWithString:[users stringByAppendingPathComponent:user.databaseId]] :
    [NSURL URLWithString:users];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = isExistingUser ? @"PUT" : @"POST";
    
    // get JSON converted Spot for uploading to server
    NSData* data = [NSJSONSerialization dataWithJSONObject:[user toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            if (isExistingUser) {
                // do nothing bc response array just has success msg
                NSLog(@"User updated on server");
                // TODO: maybe here I should save a timestamp for most recent update?
            } else {
                NSLog(@"User saved to server");
                // get _id from returned data and save it to the User databaseId property
                user.databaseId = responseArray[0][0][@"_id"];
                [[NSUserDefaults standardUserDefaults] setObject:user.databaseId forKey:@"thisUserId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
    [dataTask resume];
}

#pragma mark - Spots
// creates the required query for returning Spots within an MKCoordinateRegion
- (void) queryRegion:(MKCoordinateRegion)region handleResponse:(void (^)(NSDictionary*))spotHandlingBlock {
    // TODO: fix cross hemisphere logic?
    //note assumes the NE hemisphere. This logic should really check first.
    //also note that searches across hemisphere lines are not interpreted properly by Mongo
    CLLocationDegrees x0 = region.center.longitude - region.span.longitudeDelta/2;
    CLLocationDegrees x1 = region.center.longitude + region.span.longitudeDelta/2;
    CLLocationDegrees y0 = region.center.latitude - region.span.latitudeDelta/2;
    CLLocationDegrees y1 = region.center.latitude + region.span.latitudeDelta/2;
    
    NSString* boxQuery = [NSString stringWithFormat:@"{\"$geoWithin\":{\"$box\":[[%f,%f],[%f,%f]]}}",x0,y0,x1,y1];
    NSString* locationInBox = [NSString stringWithFormat:@"{\"location\":%@}", boxQuery];
    NSString* escBox = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                             (CFStringRef) locationInBox,
                                                                                             NULL,
                                                                                             (CFStringRef) @"!*();':@&=+$,/?%#[]{}",
                                                                                             kCFStringEncodingUTF8));
    NSString* query = [NSString stringWithFormat:@"?query=%@", escBox];
    [self runSpotQuery:query handleResponse:spotHandlingBlock];
}

- (void) runSpotQuery:(NSString *)queryString handleResponse:(void (^)(NSDictionary*))spotHandlingBlock {
    NSString* urlStr = [[kBaseURL stringByAppendingPathComponent:kSpots] stringByAppendingString:queryString];
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            spotHandlingBlock(responseDictionary);
            
            NSLog(@"received %lu items", (unsigned long)responseDictionary.count);
        }
    }];
    [dataTask resume];
}

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
        // TODO: error?
        NSLog(@"Error saving spot to server");
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
                NSLog(@"Spot updated on server");
                // TODO: maybe here I should save a timestamp for most recent update?
            } else {
                NSLog(@"Spot saved to server");
                // get _id from returned data and save it to the Spot databaseId property
                spot.databaseId = responseArray[0][0][@"_id"];
                // TODO: if I allow multiple photos at once, do a forin
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
    if (!photo || photo.latitude == nil || photo.longitude == nil) { 
        // TODO: error?
        NSLog(@"Error saving photo to server");
        return; //input safety check
    }
    NSString* photos = [kBaseURL stringByAppendingPathComponent:kPhotos];
    
    BOOL isExistingPhoto = photo.databaseId != nil;
    NSURL* url = isExistingPhoto ? [NSURL URLWithString:[photos stringByAppendingPathComponent:photo.databaseId]] :
    [NSURL URLWithString:photos];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = isExistingPhoto ? @"PUT" : @"POST";
    
    // get converted Photo for uploading to server
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
                NSLog(@"Photo updated on server");
            } else {
                NSLog(@"Photo saved to server");
                // get _id from returned data and save it to the Photo databaseId property
                photo.databaseId = responseArray[0][0][@"_id"];
                // update Spot on server now that it can add the photo databaseId
                [self pushSpotToServer:photo.photoSpot];
                // TODO: update User to include new photo databaseId
                
                // now that photo has a databaseId, save image locally and online
                [photo receivedDatabaseId];
            }
        }
    }];
    [dataTask resume];
}

// given a Photo object, method pulls updated Photo info from server and updates core data properties
- (void)updatePhotoFromServer:(Photo*)photo {
    NSString* photoId = photo.databaseId;
    NSString* requestURL = [NSString stringWithFormat:@"%@%@/%@",kBaseURL,kPhotos,photoId];
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
                                                        dispatch_async(dispatch_get_main_queue(), ^(void){
                                                            [photo updateFromDictionary:responseDictionary];
                                                        });
                                                    }
                                                }];
    
    [dataTask resume];
}

@end
