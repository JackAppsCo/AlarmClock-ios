//
//  MKObject.h
//  MKKit
//
//  Created by Matthew King on 8/24/11.
//  Copyright (c) 2010-2011 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKObjectDelegate.h"

#define MK_REMOVE_BLOCK_OBJECT_NOTIFICATION     @"MKRemoveBlockNotification"

@protocol MKObjectDelegate;

/**--------------------------------------------------------------
 MKObject is a super class for other objects that conforms them
 to the MKObjectDelegate.
 
 *Notifications*
 
 * `MK_REMOVE_BLOCK_OBJECT_NOTIFICATION` post this notification to 
 release any block responces that an object may be holding.
---------------------------------------------------------------*/

@interface MKObject : NSObject 

///------------------------------
/// @name Observing Changes
///------------------------------

/** 
 A method for use by subclasses and catagories. Default implentaion
 does nothing.
*/
- (void)didRelease;

///------------------------------
/// @name Delegate
///------------------------------

/** the objectProtocol */
@property (nonatomic, assign) id<MKObjectDelegate> objectDelegate;

@end
