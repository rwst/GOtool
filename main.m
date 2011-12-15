#import <Foundation/Foundation.h>
#include <objc/objc-auto.h>
#include <getopt.h>
#import "GOparser.h"
#import "GOAparser.h"
#import "GOAcollection.h"
#import "version.h"

NSURL *applicationLibDirectory();
void usage();

int main (int argc, char* const* argv) {

	BOOL count_f = NO, leaves_f = NO, tab_f = NO, ana_f = NO;
	char *aspects = NULL, *analyze_opts = NULL, *infer_filename = NULL;
	int ch;
	
	/* options descriptor */
	static struct option longopts[] = {
		{ "count",      no_argument,       NULL,           'c' },
		{ "leaves-only", no_argument,      NULL,           'l' },
		{ "tab-hierarchy", no_argument,    NULL,           't' },
		{ "aspects", optional_argument,    NULL,           '3' },
		{ "analyze", optional_argument,    NULL,           'y' },
		{ "infer-from", required_argument, NULL,           'i' },
		{ NULL,         0,                   NULL,           0 }
	};
	
	while ((ch = getopt_long(argc, argv, "clty:3:i:", longopts, NULL)) != -1)
	{
		switch (ch)
		{
			case 'c':
				count_f = YES;
				break;
			case 'l':
				leaves_f = YES;
				break;
			case 't':
				tab_f = YES;
				break;

			case 'y':
				ana_f = YES;
				analyze_opts = optarg;
				break;
			case '3':
				aspects = optarg;
				break;
			case 'i':
				infer_filename = optarg;
				break;

			default:
				usage();
		}
	}
	argc -= optind;
	argv += optind;
	if (argc<2)
		usage();
	
	NSAutoreleasePool * pool = [NSAutoreleasePool alloc];
	[pool init];
    objc_startCollectorThread();
	
	//gopath = applicationLibDirectory();
	NSURL *gopath = [NSURL URLWithString:
					 [[NSString alloc] initWithCString:argv[0] encoding:NSUTF8StringEncoding]];
	NSURL *goa1path = [NSURL URLWithString:
					[[NSString alloc] initWithCString:argv[1] encoding:NSUTF8StringEncoding]];

    GOparser *parser;
	parser = [GOparser create];
	[parser setDoDiscardDefs:YES];
	GeneOntology* g = [parser parse:gopath];

	// Test case 1
	GOterm* term = [g getTermWithId: @"0000001"];
	if (term==nil)
		[NSException raise:@"TestException" format:@"Could not get term #1!"];
	if (![[term name] isEqualToString:@"mitochondrion inheritance"])
		[NSException raise:@"TestException" format:@"term #1 is not 'mitochondrion inheritance'! It is: '%s'", [[term name] UTF8String]];

	GOAparser *aparser = [GOAparser create];
	GOAcollection *gcoll = [GOAcollection create];
	[gcoll init];
	gcoll = [aparser parse:goa1path];
	[gcoll applyNOTs];

	[g makeSlim: gcoll];
	if (ana_f)
	{
		[g analyze: (analyze_opts==NULL)?nil:[[NSString alloc] initWithCString:analyze_opts
											 encoding:NSASCIIStringEncoding]];
		return 0;
	}
	if (infer_filename != NULL) {
		[g infer_from: [[NSString alloc] initWithCString:infer_filename
												encoding:NSASCIIStringEncoding]];
		return 0;
	}
	[g outputSlimAspects: (aspects==NULL)?nil:[[NSString alloc] initWithCString:aspects
												   encoding:NSASCIIStringEncoding]
			   showCount: count_f showLeavesOnly: leaves_f withTabs: tab_f];
	
//    [pool release];
	return 0;
}

NSURL *applicationLibDirectory() {
    NSString *GO_DIRECTORY = @"Gene Ontology";
    static NSURL *ald = nil;
	
    if (ald == nil) {
		
        NSFileManager *fileManager = [NSFileManager alloc];
		[fileManager init];
        NSError *error = nil;
        NSURL *libraryURL = [fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask
									   appropriateForURL:nil create:YES error:&error];
        if (libraryURL == nil) {
            NSLog(@"Could not access Library directory\n%@", [error localizedDescription]);
        }
        else {
            ald = [libraryURL URLByAppendingPathComponent:@"Application Support"];
            ald = [ald URLByAppendingPathComponent:GO_DIRECTORY];
            NSDictionary *properties = [ald resourceValuesForKeys:
                                        [NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
            if (properties == nil) {
                if (![fileManager createDirectoryAtPath:[ald path]
							withIntermediateDirectories:YES attributes:nil error:&error]) {
                    NSLog(@"Could not create directory %@\n%@",
						  [ald path], [error localizedDescription]);
                    ald = nil;
                }
            }
        }
    }
    return ald;
}

void usage()
{
	printf("makegoslim version %s\n", VERSION);
	printf("usage:   makegoslim [options] GOfile GOAfile1 [GOAfile2 ...]\n");
	printf("options: -c, --count: output gene product count for each GO id\n");
	printf("         -l, --leaves-only: show (and count) only leaves, not nodes\n");
	printf("         -t, --tab-hierarchy: use TAB indenting for hierarchy\n");
	printf("         -3, --aspects [opt. arg = C/F/P]: output separated trees for\n");
	printf("               the given (or all three if no arg) aspects\n");
	printf("               (C=component, F=function, P=process)\n\n");
	printf("example: makegoslim gene_ontology.obo ECOLI.goa\n");
	printf("         makegoslim --aspects=P -lc gene_ontology.obo ECOLI.goa MYCTU.goa\n\n");
	exit(-1);
}