//
//  JAClockSettingsViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/23/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAClockSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *_bgList, *_fontColorList;
    int _selectedPicker;
    NSDateFormatter *_dateFormatter;
}

@property (strong, nonatomic) UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISwitch *showSecondsSwitch;

@end
