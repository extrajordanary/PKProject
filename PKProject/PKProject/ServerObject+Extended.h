//
//  ServerObject+Extended.h
//  PKProject
//
//  Created by Jordan on 10/10/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "ServerObject.h"

@interface ServerObject (Extended)

-(NSMutableArray*)arrayOfObjectIds:(NSArray*)objects;
-(NSArray*)getManagedObjects:(NSString*)entityForName withPredicate:(NSPredicate*)predicate;
-(void)updateCoreData;

@end
