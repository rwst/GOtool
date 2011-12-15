//
//  GOAparser.m
//  GOtool
//
//  Created by Ralf Stephan on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#import "GOAparser.h"
#import "GOannotation.h"

#define BUFLEN 4096

@implementation GOAparser

+ (GOAparser *)create
{
	return [[self alloc] autorelease];
}

- (GOAcollection *) parse: (NSURL *) file
{
	char bufadr[BUFLEN], *buf;
	FILE *fp;
	NSString *path = [file path];
	char pathstr[BUFLEN];
	GOannotation *goa;
	GOAcollection *coll = [GOAcollection create];
	long linecount = 0;
	int offs[NCOLUMNS];
	
	strcpy (pathstr, [path UTF8String]);
	printf ("Trying to read %s\n", pathstr);
	fp = fopen (pathstr, "r");
	if (fp == NULL)
		[NSException raise:@"ParserException" format:@"Could not read: %s!", pathstr];
	while ((buf = fgets (bufadr, BUFLEN-1, fp)) != 0)
	{
		++linecount;
		if (buf[0] == '!')
			continue;
		for (int i=0; i<NCOLUMNS; i++) offs[i] = 0;
		char *p = buf;
		int tabcount = 0;
		while (*p && p-buf<BUFLEN) {
			offs[tabcount] = p-buf;
			while (*p && *p!='\t') ++p;
			if (!*p) break;
			*p++ = '\0';
			++tabcount;
		}
		
		if (p-buf >= BUFLEN)
			[NSException raise:@"ParserException" format:@"Not enough tabs in buffer: %s!", buf];
		goa = [GOannotation alloc];
		[goa copyBuf: buf withLength: p-buf];
		[goa setOffsets: offs];
		[coll addGOA: goa];
	}
	
	printf("Having read %ld lines\n", linecount);
	return coll;
}
		
@end
