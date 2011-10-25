//
//  GOterm.h
//  GOtool
//
//  Created by Ralf Stephan on 12/7/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *rel_isa, *rel_partof, *rel_regulates, *rel_pos_reg, *rel_neg_reg;

typedef enum { GO_COMPONENT, GO_PROCESS, GO_FUNCTION } GO_namespace_t;

@interface GOterm : NSObject {
		
	NSString *def, *idstr, *parent, *name;
	NSArray *rel_type, *rel_targetid, *ass_objs, *children;
	NSObject *last_ass_obj;
	BOOL obsolete_f;
	GO_namespace_t nspace;
}

+ (void)initialize;
- (void)init;
- (void)setDef: (const char*) str;
- (NSString*)setId: (const char*) str;
- (void)setParent: (const char*) str;
- (void)setName: (const char*) str;
- (void)setNamespace: (const char*) str;
- (void)setObsoleteFlag: (const char*) str;
- (void)setRelationship: (const char*) str;
- (void)addRelationship: (NSString*) rel cstring: (const char*) str;
- (void)addAssociation: (NSObject*) obj;
- (void)addChild: (NSString*) childID;

@property(readonly) NSString *parent, *idstr, *name;
@property(readonly) NSArray *rel_type, *rel_targetid, *ass_objs, *children;
@property(readonly) NSObject *last_ass_obj;
@property(readonly) GO_namespace_t nspace;

- (void)make_readonly;

@end
