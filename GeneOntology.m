//
//  GeneOntology.m
//  GOtool
//
//  Created by Ralf Stephan on 12/5/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import "GeneOntology.h"
#include <time.h>

@implementation GeneOntology

+(GeneOntology*)create
{
	GeneOntology* g = [GeneOntology alloc];
	[g init];
	return g;
}

- (void)init
{
	dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
}

- (void)setId: (NSString*) ID forTerm: (GOterm*) term
// add (ID, GOterm) pair to dict
{
	if ([ID length] < 7)
		[NSException raise:@"TermException" format:@"Attempt to add term with id '%s'!",
		 [ID UTF8String]];
	//fprintf(stderr, "add dict entry with key:%s\n", [ID cString]);
	[dict setObject:term forKey:ID];
}

- (void) setAlt: (char*) str forTerm: (GOterm*) term;
{
	while (*str && *str==' ') ++str;
	while (*str && *str!=':') ++str;
	++str;
	char buf[8];
	for (int i=0; i<7; i++) buf[i]=*str++;
	buf[7] = '\0';
	NSString *idstr = [[NSString alloc] initWithCString:buf encoding:NSASCIIStringEncoding];
	
	[self setId:idstr forTerm: term];
}

- (GOterm*)getTermWithId: (NSString*) ID
{
	return [dict objectForKey:ID];
}

- (void)makeSlim: (GOAcollection*) gcoll
{
	for (GOannotation* goa in [gcoll getEnumerator])
		[self processUpwards: [goa getGOID] withGOA: goa withChild: [goa getGOID]];
}

- (void) processUpwards: (NSString*) GOId withGOA: (GOannotation*) goa
			  withChild: (NSString*) childID
{
	GOterm* term = [dict objectForKey:GOId];
	if (term == nil)
		[NSException raise:@"TermException" format:@"Could not get term with id '%s'!",
		 [GOId UTF8String]];
	if ([term last_ass_obj] == goa)
		return;
	[term addAssociation: goa];
	if (![childID isEqualToString: GOId])
		[term addChild: childID];
	
	NSString* parent = [term parent];
	if (parent == nil)
		return;
	[self processUpwards: parent withGOA: goa withChild: GOId];
	
	NSArray *types = [term rel_type];
	if (types == nil)
		return;
	NSArray *targetids = [term rel_targetid];
	for (int k=0; k<[types count]; k++)
	{
		//NSString *typ = [types objectAtIndex:k];
		[self processUpwards: [targetids objectAtIndex:k] withGOA: goa withChild: GOId];
	}
}

static inline int count_uniqueobids (NSArray* a)
{
	NSString *dummy = [(NSString*)[NSString alloc] init];
	if ([a count] == 1) return 1;
	NSMutableDictionary* d = [NSMutableDictionary dictionary];
	for (GOannotation* goa in a)
	{
		[d setObject: dummy forKey:[goa getDBObjectID]];
		//printf("%s ", [[goa getDBObjectID] UTF8String]);
	}
	return [d count];
}

- (void) out_topdown_from: (NSString*) top, BOOL count_f, BOOL tab_f,
							  BOOL leaves_f, int level
{
	if (!leaves_f && tab_f)
		for (int k=0; k<level; k++)
			printf("\t");
	GOterm* term = [dict objectForKey:top];
	if (term == nil)
		[NSException raise:@"TermException" format:@"Could not get term with id '%s'!",
		 [top UTF8String]];
	NSArray *children = [term children];
	if (!leaves_f || children == nil)
	{
		if (count_f) // doppelter Code
			printf("%s %s %d\n", [[term idstr] UTF8String], [[term name] UTF8String], 
				   count_uniqueobids([term ass_objs]));
		else 
			printf("%s %s\n", [[term idstr] UTF8String], [[term name] UTF8String]);
	}
	for (NSString *GOid in children)
		[self out_topdown_from: GOid, count_f, tab_f, leaves_f, level+1];
}

- (void) outputSlimAspects: (NSString*) aspects showCount: (BOOL) count_f
			showLeavesOnly: (BOOL) leaves_f withTabs: (BOOL) tab_f
{
	BOOL c_asp = YES, f_asp = YES, p_asp = YES;
	if (aspects != nil)
	{
		c_asp = [aspects rangeOfCharacterFromSet:
				 [NSCharacterSet characterSetWithCharactersInString:@"cC"]].length > 0;
		f_asp = [aspects rangeOfCharacterFromSet:
				 [NSCharacterSet characterSetWithCharactersInString:@"fF"]].length > 0;
		p_asp = [aspects rangeOfCharacterFromSet:
				 [NSCharacterSet characterSetWithCharactersInString:@"pP"]].length > 0;
		//printf("aspect flags: C:%d F:%d P:%d\n", c_asp, f_asp, p_asp);
	}
	if (!leaves_f && !tab_f)
	{
		for (GOterm* term in [dict objectEnumerator])
		{
			NSArray* arr = [term ass_objs];
			GO_namespace_t nspace = [term nspace];
			if (arr != nil && ((nspace == GO_COMPONENT && c_asp)
							   ||(nspace == GO_FUNCTION && f_asp)
							   ||(nspace == GO_PROCESS && p_asp)))
			{
				if (count_f)
					printf("%s %s %d\n", [[term idstr] UTF8String], [[term name] UTF8String], 
						   count_uniqueobids(arr));
				else 
					printf("%s %s\n", [[term idstr] UTF8String], [[term name] UTF8String]);
			}
		}
		return;
	}
	
	/*
	if ([[dict objectForKey:top] ass_objs] == nil)
		[NSException raise:@"TermException" format:@"Top term with id '%s' not associated!",
		 [top UTF8String]];
	*/
	
	if (c_asp) [self out_topdown_from:@"0005575", count_f, tab_f, leaves_f, 0];
	if (f_asp) [self out_topdown_from:@"0003674", count_f, tab_f, leaves_f, 0];
	if (p_asp) [self out_topdown_from:@"0008150", count_f, tab_f, leaves_f, 0];
}

- (void) analyze: (NSString*) options;
// the aim is to output all IDs with F-term and (no F-leaf-term or no P-leaf-term)
// however it would be useful to have the two lists not mixed: 1. F and no F-leaf
// and 2. F and no P-leaf, and to see all F and P annotations of an ID at once.
{
	NSMutableDictionary* allf = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
	[self anaf_topdown_from:@"0003674" withDB: allf];
	[self anap_topdown_from:@"0008150" withDB: allf];
	for (NSString* objid in allf)
	{
		int f = [[allf objectForKey:objid] intValue];
		printf("%c%c%c%c %s\n", (f&1)?'X':'-', (f&2)?'x':'-', (f&4)?'Y':'-', (f&8)?'y':'-', [objid UTF8String]);
	}
}

- (void) anaf_topdown_from: (NSString*) top withDB: (NSMutableDictionary*) allf
{
	GOterm* term = [dict objectForKey:top];
	if (term == nil)
		[NSException raise:@"TermException" format:@"Could not get term with id '%s'!",
		 [top UTF8String]];
	
	NSArray *children = [term children];
	NSInteger flags = (children == nil)? 1:2;
	for (GOannotation* goa in [term ass_objs])
	{
		NSString *objid = [goa getDBObjectID];
		NSNumber *flagres = [allf objectForKey:objid];
		NSInteger flagres_int;
		if (flagres != nil)
		{
			flagres_int = [flagres intValue];
			flagres_int = flagres_int | flags;
		}
		else
			flagres_int = flags;
		[allf setObject: [NSNumber numberWithInt: flagres_int] forKey:objid];
	}	
	
	for (NSString *GOid in children)
		[self anaf_topdown_from: GOid withDB:allf];
}

- (void) anap_topdown_from: (NSString*) top withDB: (NSMutableDictionary*) allf
{
	GOterm* term = [dict objectForKey:top];
	if (term == nil)
		[NSException raise:@"TermException" format:@"Could not get term with id '%s'!",
		 [top UTF8String]];
	
	NSArray *children = [term children];
	NSInteger flags = (children == nil)? 4:8;
	for (GOannotation* goa in [term ass_objs])
	{
		NSString *objid = [goa getDBObjectID];
		NSNumber *flagres = [allf objectForKey:objid];
		NSInteger flagres_int;
		if (flagres != nil)
		{
			flagres_int = [flagres intValue];
			flagres_int = flagres_int | flags;
		}
		else
			flagres_int = flags;
		[allf setObject: [NSNumber numberWithInt: flagres_int] forKey:objid];
	}	
	
	for (NSString *GOid in children)
		[self anap_topdown_from: GOid withDB:allf];
}

#define BUFLEN 4096
NSString *dummy;
NSMutableDictionary* output_ht;

- (void) infer_from: (NSString*) filename
{
	char bufadr[BUFLEN], *buf;
	FILE *fp;
	char pathstr[BUFLEN];
	long linecount = 0;
	GOterm *pre = nil;
	NSMutableArray* cset = nil;
	dummy = [(NSString*)[NSString alloc] init];
	output_ht = [NSMutableDictionary dictionary];
	
	strcpy (pathstr, [filename UTF8String]);
	printf ("Trying to read %s\n", pathstr);
	fp = fopen (pathstr, "r");
	if (fp == nil)
		[NSException raise:@"ParserException" format:@"Could not read: %s!", pathstr];
	while ((buf = fgets (bufadr, BUFLEN-1, fp)) != 0)
	{
		++linecount;
		if (buf[0] == '!')
			continue;
		buf[strlen(buf)-1] = '\0';
		char *ptr = buf;
		while (*ptr && isspace(*ptr) ) ++ptr;
		if (*ptr == '\0') {
			continue;
		}
		ptr[7] = '\0';
		GOterm* term = [dict objectForKey: [[NSString alloc] initWithCString:ptr
															encoding:NSASCIIStringEncoding]];
		if (term == nil)
			[NSException raise:@"TermException" format:@"Could not get term with id '%s'!",
			 ptr];
		char *ptr1 = ptr+8;
		while (*ptr1 && isspace(*ptr1) ) ++ptr1;
		if (![[[NSString alloc] initWithCString:ptr1 
								encoding:NSASCIIStringEncoding] isEqualToString: [term name]]) {
			[NSException raise:@"ParserException" format:@"Given name does not match that in GO: %s!", ptr1];			
		}
		if (ptr == buf) { /* new rule block */
			if (cset == nil) --linecount;
			if (pre != nil)
				[self do_infer_with: pre concl: cset];
			pre = term;
			cset = nil;
		}
		else {
			if (cset == nil)
				cset = [NSMutableArray arrayWithCapacity:3];
			[cset addObject: term];
		}
	}
	if (pre != nil)
		[self do_infer_with: pre concl: cset];
	fprintf(stderr, "Applied %ld rule blocks\n", --linecount);
}

- (void) do_infer_with: (GOterm*) pre concl: (NSArray*) conclusions
{
	if (conclusions == nil) {
//		[NSException raise:@"ParserException" format:@"Conclusions is nil!"];
		return;
		}
	char buf[BUFLEN];
	for (GOannotation* goa in [pre ass_objs])
	{
		NSString *objid = [goa getDBObjectID];
		NSString *refs = [goa getRefs];
//		printf("changing: %s %s\n", [objid UTF8String], [refs UTF8String]);
		for (GOterm *cc in conclusions)
		{
			bool found_f = NO;
			for (GOannotation* goc in [cc ass_objs])
			{
				if ([objid isEqualToString: [goc getDBObjectID]] &&
					[refs  isEqualToString: [goc getRefs]])
				{ found_f = YES; break; }
			}
			if (!found_f) { /* output inferred annotation */
				memcpy (buf, [goa buffer], [goa length]);
				buf[[goa length]] = '\0';
				GOterm *term = cc;
				NSString *id = [term idstr];
				strncpy (buf + [goa offsets][GOAF_GOID] + 3,
						 [id UTF8String], 7);
				while (![id isEqualToString:@"0005575"] &&
					   ![id isEqualToString:@"0003674"] &&
					   ![id isEqualToString:@"0008150"]) {
					term = [self getTermWithId: [term parent]];
					if (term == nil) {
						[NSException raise:@"TermException"
									format:@"Blood and martyrs, no top parent found!"];
						return;
					}
					id = [term idstr];
				}
				char *aspect = buf + [goa offsets][GOAF_ASPECT];
				if ([id isEqualToString:@"0005575"]) *aspect = 'C';
				if ([id isEqualToString:@"0003674"]) *aspect = 'F';
				if ([id isEqualToString:@"0008150"]) *aspect = 'P';
				
				time_t t = time(NULL);
				int offs = [goa offsets][GOAF_DATE];
				strftime(buf+offs, 8, "%Y%m%d", localtime(&t));
				
				for (int n=1; n<NCOLUMNS; n++)
					if ([goa offsets][n] > 0) 
						buf[[goa offsets][n]-1] = '\t';
				
				NSString *key = [[id stringByAppendingString:objid] stringByAppendingString:refs];
				if ([output_ht objectForKey: key] == nil)
				{
					[output_ht setObject: dummy forKey:key];
					printf("%s", buf);
				}
			}
		}
	}
}

@end
