//
//  GOparser.h
//  GOtool
//
//  Created by Ralf Stephan on 12/5/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneOntology.h"

@interface GOparser : NSObject {

	BOOL doDiscardDefs;
}

@property(readwrite) BOOL doDiscardDefs;

+ (GOparser *)create;
- (GeneOntology *) parse: (NSURL *) file;

@end
