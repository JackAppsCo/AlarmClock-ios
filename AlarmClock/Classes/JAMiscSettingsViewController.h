//
//  JAMiscSettingsViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/28/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMiscSettingsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    int _selectedPicker, _selectedSound, _selectedTime;
    
}

@property (strong, nonatomic) UISegmentedControl *weatherSwitch;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *sounds;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISwitch *shineSwitch;

@end
