//
//  MKObject.m
//  MKKit
//
//  Created by Matthew King on 8/24/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKObject.h"


@implementation MKObject

@synthesize objectDelegate;

#pragma mark - Memory Managment

- (void)didRelease {
    //For use by sublcasses and categories.
}

- (void)dealloc {
    [self didRelease];
    
    [super dealloc];
}

@end
