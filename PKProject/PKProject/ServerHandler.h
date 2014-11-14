//
//  DatabaseHandler.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class User;
@class Spot;
@class Photo;
@class ServerObject;

@interface ServerHandler : NSObject <MKMapViewDelegate>

+ (id) sharedServerHandler;

-(void)updateObjectFromServer:(ServerObject*)object;
-(void)updateUserFromServer:(User*)user;
-(void)pushUserToServer:(User*)user;
-(void)queryFacebookId:(NSString*)facebookId handleResponse:(void (^)(NSArray*))responseHandlingBlock;
-(void)queryRegion:(MKCoordinateRegion)region handleResponse:(void (^)(NSDictionary*))spotHandlingBlock;
-(void)getSpotsFromServer:(void (^)(NSDictionary*))spotHandlingBlock;
-(void)pushSpotToServer:(Spot*)spot;
-(void)pushPhotoToServer:(Photo*)photo;

@end
