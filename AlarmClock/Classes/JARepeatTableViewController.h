//
//  JARepeatTableViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/21/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAAlarm.h"

@protocol JARepeatTableViewControllerDelegate;

@interface JARepeatTableViewController : UITableViewController

@property (strong, nonatomic) JAAlarm *alarm;
@property (strong, nonatomic) NSMutableArray *repeatDays;
@property (nonatomic, retain) id <JARepeatTableViewControllerDelegate> delegate;

- (id)initWithAlarm:(JAAlarm*)theAlarm;

@end

@protocol JARepeatTableViewControllerDelegate

- (void) repeatTableViewController:(JARepeatTableViewController *)controller choseDays:(NSArray *)days;

@end
