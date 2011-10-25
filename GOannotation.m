//
//  GOannotation.m
//  GOtool
//
//  Created by Ralf Stephan on 12/11/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#include <string.h>
#import "GOannotation.h"

@implementation GOannotation

-(void)copyBuf: (const char*) buf withLength: (int) len
{
	buffer = malloc((len+1)*sizeof(char));
	memcpy (buffer, buf, len);
	buffer[len-1] = '\0';
}

-(void)setOffsets: (int*)offs
{
	offsets = malloc(NCOLUMNS*sizeof(int));
	memcpy (offsets, offs, NCOLUMNS*sizeof(int));
	*(buffer+offsets[GOAF_GOID]+10) = '\0';
}

-(void)release
{
	free(buffer);
	free(offsets);
}

//-(NSString *)getDB;

-(NSString *)getDBObjectID
{
	buffer[offsets[GOAF_DBOBJID]+10] = '\0';
	return [[NSString alloc] initWithCString:buffer+offsets[GOAF_DBOBJID]
									encoding:NSASCIIStringEncoding];
}

//-(NSString *)getDBObjectSymbol;

-(GOA_qual_t)getQualifier
{
	return strncmp(buffer+offsets[GOAF_QUALIFIER], "NOT", 3)? GOAQ_NONE:GOAQ_NOT;
}

-(NSString *)getGOID
{
	return [[NSString alloc] initWithCString:buffer+offsets[GOAF_GOID]+3
									encoding:NSASCIIStringEncoding];
}

-(NSString *)getRefs
{
	return [[NSString alloc] initWithCString:buffer+offsets[GOAF_REFS]
									encoding:NSASCIIStringEncoding];
}

-(NSString *)getEvidence
{
	return [[NSString alloc] initWithCString:buffer+offsets[GOAF_EVIDENCE]
									encoding:NSASCIIStringEncoding];
}

//-(NSString *)getWith;
//-(NSString *)getAspect;
//-(NSString *)getObjName;
//-(NSString *)getSynonyms;
//-(NSString *)getType;

-(NSString *)getTaxon
{
	return [[NSString alloc] initWithCString:buffer+offsets[GOAF_TAXON]
									encoding:NSASCIIStringEncoding];
}

//-(NSString *)getDate;

-(NSString *)getAssigned
{
	return [[NSString alloc] initWithCString:buffer+offsets[GOAF_ASSIGNED]
									encoding:NSASCIIStringEncoding];
}

//-(NSString *)getExtension;
//-(NSString *)getProductForm;

@end
