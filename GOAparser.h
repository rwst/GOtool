//
//  GOAparser.h
//  GOtool
//
//  Created by Ralf Stephan on 12/11/10.
//  Copyright 2010 <mailto:ralf@ark.in-berlin.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOAcollection.h"

@interface GOAparser : NSObject {
	
}

+ (GOAparser *)create;
- (GOAcollection *) parse: (NSURL *) file;


@end
