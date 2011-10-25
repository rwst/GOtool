//
//  GOAcollection.m
//  GOtool
//
//  Created by Ralf Stephan on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GOAcollection.h"


@implementation GOAcollection

+(GOAcollection*)create
{
	GOAcollection* g = [GOAcollection alloc];
	[g init];
	return g;
}

-(void)init
{
	allset = [NSMutableSet setWithCapacity: INITIAL_SET_CAPACITY];
	notset = nil;
}

-(void)addGOA: (GOannotation *)goa
{
	if ([goa getQualifier] != GOAQ_NOT) 
		[(NSMutableSet*)allset addObject:goa];
	else {
		if (notset == nil) {
			notset = [[NSMutableDictionary alloc] initWithCapacity:16];
		}
		[notset setObject:goa
				   forKey:[[goa getDBObjectID] stringByAppendingString:[goa getGOID]]];
	}
}

-(void)applyNOTs
{
	if (notset == nil)
		return;
	
	BOOL (^doesntmatch)(id obj, BOOL *stop);
	doesntmatch = ^(id obj, BOOL *stop)
	{
		NSString *key = [[obj getDBObjectID] stringByAppendingString:
						 [obj getGOID]];
		if ([notset objectForKey:key] == nil)
			return YES;
		else 
			return NO; // ADC! why not return (...)?YES:NO; ??
	};
	
	allset = [(NSMutableSet*)allset objectsPassingTest:doesntmatch];
	fprintf(stderr, "Applied %d NOT annotations.\n", (int)[notset count]);
}

-(NSEnumerator*)getEnumerator
{
	return [allset objectEnumerator];
}
@end
