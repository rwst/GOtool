//
//  GOparser.m
//  GOtool
//
//  Created by Ralf Stephan on 12/5/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#import "GOparser.h"
#import "GOterm.h"

#define BUFLEN 4096

@implementation GOparser

+ (GOparser *)create
{
	return [[self alloc] autorelease];
}

@synthesize doDiscardDefs;

- (GeneOntology *) parse: (NSURL *) file
{
	char bufadr[BUFLEN], *buf;
	FILE *fp;
	BOOL new_term_f = NO;
	NSString *path = [file path], *termid;
	char pathstr[BUFLEN];
	GOterm *term;
	GeneOntology *g = [GeneOntology create];
	long linecount = 0, termcount = 0;
	
	strcpy (pathstr, [path UTF8String]);
	printf ("Trying to read %s\n", pathstr);
	fp = fopen (pathstr, "r");
	if (fp == NULL)
		[NSException raise:@"ParserException" format:@"Could not read: %s!", pathstr];
	while ((buf = fgets (bufadr, BUFLEN-1, fp)) != 0)
	{
		++linecount;
		if (!strncmp(buf, "[Term]", 6)) {
			if (new_term_f) {
				[g setId: termid forTerm: term];
			}
			new_term_f = YES;
			term = [GOterm alloc];
			[term init];
			++termcount;
			continue;
		} else { 
			if (!new_term_f) { // ignore header data
				continue;
			}
		}

		// we recognize
		// "alt_id", "def", "id", "is_a", "is_obsolete", "name", "namespace", "relationship".
		switch (buf[0]) {
			case 'a':
				if (!strncmp(&(buf[0]), "alt_id:", 7)) {
					[g setAlt: &(buf[7]) forTerm: term];
				}
				break;
			case 'd': 
				if (!strncmp(&(buf[0]), "def:", 4)) {
					if (!doDiscardDefs) {
						[term setDef: &(buf[4]) ];
					}
				}
				break;
			case 'i':
				if (buf[1] == 'd') {
					//fprintf(stderr, "%s\n", buf+3);
					termid = [term setId: &(buf[7]) ];
				} else if (buf[1] == 's') {
					if (buf[2] == '_' && buf[3] == 'a' && buf[4] == ':') {
						[term setParent: &(buf[9]) ];
					} else if (!strncmp(&(buf[2]), "_obsolete:", 10)) {
						[term setObsoleteFlag: &(buf[12]) ];
					}
				}
				break;
			case 'n':
				if (!strncmp(&(buf[1]), "ame", 3)) {
					if (buf[4] == ':') {
						char *pp = strchr(&(buf[5]), '\n');
						if (pp != NULL) *pp = '\0';
						[term setName: &(buf[5]) ];
					} else if (!strncmp(&(buf[4]), "space:", 6)) {
						[term setNamespace: &(buf[10]) ];
					}
				} 
				break;
			case 'r':
				if (!strncmp(&(buf[1]), "elationship:", 12)) {
					[term setRelationship: &(buf[13]) ];
				}
				break;

			default: 
				break;
		}
	}
					
	fprintf (stderr, "GOparser read %ld lines and created %ld terms.\n", linecount, termcount);
	return g;
}

@end
