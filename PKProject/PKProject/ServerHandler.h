//
//  DatabaseHandler.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Spot;
@class Photo;
@class ServerObject;

@interface ServerHandler : NSObject

@property (nonatomic, retain) NSString *myUserId;

+ (id) sharedServerHandler;

-(void)updateObjectFromServer:(ServerObject*)object;
-(void)updateUserFromServer:(User*)user;
-(void)getSpotsFromServer:(void (^)(NSDictionary*))spotHandlingBlock;
-(void)pushSpotToServer:(Spot*)spot;
-(void)pushPhotoToServer:(Photo*)photo;

@end
