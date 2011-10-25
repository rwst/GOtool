//
//  GOAcollection.h
//  GOtool
//
//  Created by Ralf Stephan on 12/12/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOannotation.h"

#define INITIAL_SET_CAPACITY 128

@interface GOAcollection : NSObject {

	NSSet *allset;
	NSMutableDictionary *notset;
}

+(GOAcollection*)create;
-(void)init;
-(void)addGOA: (GOannotation *)goa;
-(void)applyNOTs;
-(NSEnumerator*)getEnumerator;

@end
