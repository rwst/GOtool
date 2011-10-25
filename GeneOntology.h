//
//  GeneOntology.h
//  GOtool
//
//  Created by Ralf Stephan on 12/5/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOterm.h"
#import "GOAcollection.h"

@interface GeneOntology : NSObject {
	NSMutableDictionary* dict;
}

+(GeneOntology*)create;
- (void) init;
- (void) setId: (NSString*) ID forTerm: (GOterm*) term;
- (void) setAlt: (char*) altID forTerm: (GOterm*) term;
- (GOterm *) getTermWithId: (NSString*) ID;
- (void) makeSlim: (GOAcollection*) gcoll;
- (void) processUpwards: (NSString*) GOId withGOA: (GOannotation*) goa
			  withChild: (NSString*) childId;
- (void) outputSlimAspects: (NSString*) aspects showCount: (BOOL) count_f
			showLeavesOnly: (BOOL) leaves_f withTabs: (BOOL) tab_f;
- (void) out_topdown_from: (NSString*) top, BOOL count_f, BOOL tab_f,
	BOOL leaves_f, int level;
- (void) analyze: (NSString*) options;
- (void) anaf_topdown_from: (NSString*) top withDB: (NSMutableDictionary*) allf;
- (void) anap_topdown_from: (NSString*) top withDB: (NSMutableDictionary*) allf;


@end
