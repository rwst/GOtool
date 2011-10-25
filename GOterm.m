//
//  GOterm.m
//  GOtool
//
//  Created by Ralf Stephan on 12/7/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import "GOterm.h"

NSString *rel_isa, *rel_partof, *rel_regulates, *rel_pos_reg, *rel_neg_reg;

@implementation GOterm

@synthesize parent, idstr, name, rel_type, rel_targetid, ass_objs, children,
	last_ass_obj, nspace;

+ (void)initialize
{
	if (self == [GOterm class]) {
        rel_isa = @"IS_A";
        rel_partof = @"PART_OF";
        rel_regulates = @"REGULATES";
        rel_pos_reg = @"POS_REG";
        rel_neg_reg = @"NEG_REG";
    }
}

- (void)init
{
	parent = nil;
	rel_type = nil;
	rel_targetid = nil;
	ass_objs = nil;
	children = nil;
	last_ass_obj = nil;
}

- (void)setDef: (const char*) str
{
	while (*str && *str==' ' && *str=='"') ++str;
	def = [[NSString alloc] initWithCString:str encoding:NSASCIIStringEncoding];
}

- (NSString*)setId: (const char*) str
{
	while (*str && *str==' ') ++str;
	char buf[8];
	for (int i=0; i<7; i++) buf[i]=*str++;
	buf[7] = '\0';
	idstr = [[NSString alloc] initWithCString:buf encoding:NSASCIIStringEncoding];
	return idstr;
}

- (void)setParent: (const char*) str
{
	char buf[8];
	for (int i=0; i<7; i++) buf[i]=*str++;
	buf[7] = '\0';
	if (parent==nil) {
		parent = [[NSString alloc] initWithCString:buf encoding:NSASCIIStringEncoding];
	}
	else {
		[self addRelationship: rel_isa cstring:buf];
	}
}

- (void)setName: (const char*) str
{
	while (*str && *str==' ') ++str;
	name = [[NSString alloc] initWithCString:str encoding:NSASCIIStringEncoding];
}

- (void)setNamespace: (const char*) str
{
	while (*str && *str==' ') ++str;
	switch (*str) {
		case 'b':
			if (!strncmp(str, "biological_process", 18)) {
				nspace = GO_PROCESS;
				break;
			}
		case 'c':
			if (!strncmp(str, "cellular_component", 18)) {
				nspace = GO_COMPONENT;
				break;
			}
		case 'm':
			if (!strncmp(str, "molecular_function", 18)) {
				nspace = GO_FUNCTION;
				break;
			}
		default: [NSException raise:@"ParserException" format:@"Unknown namespace: %s!", str];
			break;
	}
}

- (void)setObsoleteFlag: (const char*) str
{
	obsolete_f = YES;
}

- (void)setRelationship: (const char*) str
{
	while (*str && *str==' ') ++str;
	switch (*str) {
		case 'n':
			if (!strncmp(str, "negatively_regulates", 20)) {
				str += 20;
				while (*str && *str==' ') ++str;
				[self addRelationship: rel_neg_reg cstring: str+3];
			}
			break;
		case 'p':
			if (!strncmp(str, "part_of", 7)) {
				str += 7;
				while (*str && *str==' ') ++str;
				[self addRelationship: rel_partof cstring: str+3];
				} else if (!strncmp(str, "positively_regulates", 20)) {
				str += 20;
				while (*str && *str==' ') ++str;
				[self addRelationship: rel_pos_reg cstring: str+3];				
			}
			break;
		case 'r':
				if (!strncmp(str, "regulates", 9)) {
				str += 9;
				while (*str && *str==' ') ++str;
				[self addRelationship: rel_regulates cstring: str+3];
			break;
		   }
		default: //[NSException raise:@"ParserException" format:@"Unknown relationship: %s!", str];
		   break;
	}
}

- (void)addRelationship: (NSString*) rel cstring: (const char*) str
{
	while (*str && *str==' ') ++str;
	char buf[8];
	for (int i=0; i<7; i++) buf[i]=*str++;
	buf[7] = '\0';
	NSString *s = [[NSString alloc] initWithCString:buf encoding:NSASCIIStringEncoding];
	if (rel_type == nil) {
		rel_type = [NSMutableArray array];
		rel_targetid = [NSMutableArray array];
	}
	[(NSMutableArray*)rel_type addObject:rel];
	[(NSMutableArray*)rel_targetid addObject:s];
}

- (void)addAssociation: (NSObject*) obj
{
	last_ass_obj = obj;
	if (ass_objs == nil)
		ass_objs = [NSMutableArray array];
	[(NSMutableArray*)ass_objs addObject:obj];
}

- (void)addChild: (NSString*) childID
{
	if (children == nil)
	{
		children = [NSMutableArray array];
		[(NSMutableArray*)children addObject:childID];
	}
	else
	{
		BOOL (^test)(id obj, NSUInteger idx, BOOL *stop);
		test = ^ (id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isEqualToString: childID]) return YES;
			return NO;
		};
		if ([children indexOfObjectPassingTest: test] == NSNotFound) 
		 [(NSMutableArray*)children addObject:childID];
	}
}

- (void)make_readonly
{
	if (rel_type != nil)
	{
		rel_type = [NSArray arrayWithArray:rel_type];
		rel_targetid = [NSArray arrayWithArray:rel_targetid];
	}
}

@end
