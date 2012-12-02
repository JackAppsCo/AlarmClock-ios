//
//  JAAlarmSettingsController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAAlarm.h"
#import "JASoundSelectorTableViewController.h"


@interface JAAlarmSettingsController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, JASoundSelectorTableViewControllerDelegate>
{
    BOOL pressedCancel;
}

@property (nonatomic, retain) JAAlarm *alarm;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (strong, nonatomic) UISwitch *enableSwitch;
@property (strong, nonatomic) UITextField *nameField, *snoozeField;

- (id)initWithAlarm:(JAAlarm*)anAlarm;

@end
