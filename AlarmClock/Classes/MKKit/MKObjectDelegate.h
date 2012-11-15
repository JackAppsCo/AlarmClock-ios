//
//  MKObjectProtocol.h
//  MKKit
//
//  Created by Matthew King on 8/24/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>

/**-------------------------------------------------------------------
 The MKObjectDelegate gives standard methods to be used with MKKit 
 objects.
--------------------------------------------------------------------*/

@protocol MKObjectDelegate <NSObject>

@optional

///-----------------------------------
/// @name Notification Control
///-----------------------------------

/**
 Allow the toggling of responces to registered notifications. Return `YES`
 to respond to notifications `NO` to ignore them. Default is `YES`.
 
 @param MKObject the object that will recive the notification
 
 @param name the the name of the notification.
*/
- (BOOL)object:(id)MKObject shouldObserveNotificationNamed:(NSString *)name;

@end
