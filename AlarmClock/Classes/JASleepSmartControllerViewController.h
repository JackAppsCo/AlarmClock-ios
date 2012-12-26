//
//  JASleepSmartControllerViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 12/24/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASleepSmartControllerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    int _selectedPicker, _selectedSound, _selectedTime;
    NSDateFormatter *_formatter;
}

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *sounds;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISwitch *shineSwitch;
@property (strong, nonatomic) UISegmentedControl *sleepWakeControl;
@property (strong, nonatomic) UIButton *timeButton, *createButton;
@property (strong, nonatomic) UIBarButtonItem *dateDoneButton;
@property (strong, nonatomic) UILabel *sleepLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *dateToolbar;
@property (strong, nonatomic) NSDateComponents *timeComponents;


@end
