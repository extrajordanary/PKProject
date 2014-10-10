//
//  ServerObjects.h
//  PKProject
//
//  Created by Jordan on 10/10/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ServerObjects : NSManagedObject

@property (nonatomic, retain) NSString * databaseId;

-(NSMutableArray*)arrayOfObjectIds:(NSSet*)objects;

@end
