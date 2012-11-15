//
//  JAAlarmSettingsController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAAlarm.h"

@interface JAAlarmSettingsController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) JAAlarm *alarm;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIDatePicker *datePicker;

- (id)initWithAlarm:(JAAlarm*)anAlarm;

@end
