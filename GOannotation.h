//
//  GOannotation.h
//  GOtool
//
//  Created by Ralf Stephan on 12/11/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NCOLUMNS 17 // GAF 2.0 has 17 columns

enum GOA_field_t {
	GOAF_DB=0, GOAF_DBOBJID, GOAF_DBOBJSYMBOL, GOAF_QUALIFIER, GOAF_GOID,
	GOAF_REFS, GOAF_EVIDENCE, GOAF_WITH, GOAF_ASPECT, GOAF_OBJNAME,
	GOAF_SYNONYMS, GOAF_PRODTYPE, GOAF_TAXON, GOAF_DATE, GOAF_ASSIGNED,
	GOAF_EXT, GOAF_PRODFORM
};

typedef enum { GOAQ_NONE=0, GOAQ_NOT, GOAQ_COLOCALIZES, GOAQ_CONTRIBUTES } GOA_qual_t;

@interface GOannotation : NSObject {
	char *buffer;
	int *offsets;
	
}

-(void)copyBuf: (const char*) buf withLength: (int) len;
-(void)setOffsets: (int*)offs;

//-(NSString *)getDB;
-(NSString *)getDBObjectID;
//-(NSString *)getDBObjectSymbol;
-(GOA_qual_t)getQualifier;
-(NSString *)getGOID;
-(NSString *)getRefs;
-(NSString *)getEvidence;
//-(NSString *)getWith;
//-(NSString *)getAspect;
//-(NSString *)getObjName;
//-(NSString *)getSynonyms;
//-(NSString *)getType;
-(NSString *)getTaxon;
//-(NSString *)getDate;
-(NSString *)getAssigned;
//-(NSString *)getExtension;
//-(NSString *)getProductForm;


@end
