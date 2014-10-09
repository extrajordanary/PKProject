//
//  DatabaseHandler.h
//  PKProject
//
//  Created by Jordan on 10/3/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface ServerHandler : NSObject

@property (nonatomic, retain) NSString *myUserId;

+ (id) sharedServerHandler;
- (void)updateUserFromServer:(User*)user;
-(void)getSpotsFromServer:(void (^)(NSDictionary*))spotHandlingBlock;

@end
