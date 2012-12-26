//
//  JASleepSmartControllerViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 12/24/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASleepSmartControllerViewController.h"
#import "JASettings.h"
#import "JAAlarm.h"
#import "JAAlarmSettingsController.h"

@interface JASleepSmartControllerViewController ()
- (void)shineSwitchChanged:(id)sender;

- (void) raiseDatePicker;
- (void) lowerDatePicker;
- (void) togglePicker;

- (void) raisePicker;
- (void) lowerPicker;

- (void) controlChanged:(id)sender;
- (void) createButtonPressed:(id)sender;
- (void) dateChanged:(id)sender;

@end

@implementation JASleepSmartControllerViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        //setup tableview
        [self setTableView:[[UITableView alloc] initWithFrame:CGRectInset(self.view.frame, 0, 0) style:UITableViewStyleGrouped]];
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 95.0, 0)];
        [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 95.0, 0)];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:self.tableView];

        
        //set picker and sound
        _selectedPicker = 0;
        _selectedSound = 0;
        _selectedTime = [JASettings snoozeLength];
        [self setTimeComponents:nil];
        
        //setup the dictionary from Settings.plist
		NSString *soundsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sleepSoundsList.plist"];
		NSDictionary *soundsDict = [[NSDictionary alloc] initWithContentsOfFile:soundsLocation];
        [self setSounds:[soundsDict objectForKey:@"sounds"]];
        
        //check for preselected sound
        NSDictionary *soundDict = [JASettings sleepSound];
        for (NSDictionary *thisSound in self.sounds) {
            if ([[soundDict objectForKey:@"name"] isEqualToString:[thisSound objectForKey:@"name"]]) {
                _selectedSound = [self.sounds indexOfObject:thisSound];
                break;
            }
        }
        
        //setup picker
        [self setPickerView:[[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 220)]];
        [self.view addSubview:self.pickerView];
        [self.pickerView setDelegate:self];
        [self.pickerView setShowsSelectionIndicator:YES];
        [self.pickerView setDataSource:self];
        
        //shine switch
        [self setShineSwitch:[[UISwitch alloc] init]];
        [self.shineSwitch setOn:[JASettings shine]];
        [self.shineSwitch addTarget:self action:@selector(shineSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        //Sleep Calc
        //-----------
        //sleep control
        [self setSleepWakeControl:[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Wake By", nil), NSLocalizedString(@"Sleep By", nil), nil]]];
        [self.sleepWakeControl setFrame:CGRectMake(15, 50, self.view.frame.size.width - 30, 40)];
        [self.sleepWakeControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.sleepWakeControl setSelectedSegmentIndex:0];
        [self.sleepWakeControl addTarget:self action:@selector(controlChanged:) forControlEvents:UIControlEventValueChanged];
        
        //time button
        [self setTimeButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
        [self.timeButton setFrame:CGRectOffset(self.sleepWakeControl.frame, 0, self.sleepWakeControl.frame.size.height + 10)];
        [self.timeButton setClipsToBounds:YES];
        [self.timeButton setTitle:NSLocalizedString(@"Select a Time", nil) forState:UIControlStateNormal];
        [self.timeButton addTarget:self action:@selector(togglePicker) forControlEvents:UIControlEventTouchUpInside];
        [self.timeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.timeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        
        //create button
        [self setCreateButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
        [self.createButton setFrame:CGRectMake(15, 10, self.view.frame.size.width - 30, 45.0)];
        [self.createButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self.createButton setTitle:NSLocalizedString(@"Create Alarm", nil) forState:UIControlStateNormal];
        [self.createButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.createButton setEnabled:NO];
        
        //label
        [self setSleepLabel:[[UILabel alloc] initWithFrame:CGRectMake(15, self.timeButton.frame.size.height + self.timeButton.frame.origin.y + 15, self.view.frame.size.width - 30, 50)]];
        [self.sleepLabel setBackgroundColor:[UIColor clearColor]];
        [self.sleepLabel setNumberOfLines:0];
        [self.sleepLabel setText:@"THIS IS THE LABEL/nLINE TWO"];
        
        //setup companies toolbar
        [self setDateToolbar:[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 35.0)]];
        UIBarButtonItem *flexSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setDateDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(lowerDatePicker)]];
        [self.dateToolbar setItems:[NSArray arrayWithObjects:flexSpace3, self.dateDoneButton, nil]];
        
        //date picker
        [self setDatePicker:[[UIDatePicker alloc] init]];
        [self.datePicker setDatePickerMode:UIDatePickerModeTime];
        CGRect pickerFrame = self.datePicker.frame;
        pickerFrame.origin.y = self.view.frame.size.height + self.dateToolbar.frame.size.height;
        [self.datePicker setFrame:pickerFrame];
        [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.datePicker];
        [self.view addSubview:self.dateToolbar];
        
        [self.createButton addTarget:self action:@selector(createButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //date formatter
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"h:mm a"];
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.sleepLabel.text = NSLocalizedString(@"You try to fall asleep at one of these times:", nil);
    self.createButton.enabled = NO;
    
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.timeButton.titleLabel.text.length == 0) {
        [self.datePicker setDate:[NSDate dateWithTimeInterval:(60 * 10) sinceDate:[NSDate date]]];
        [self.timeButton.titleLabel setText:[_formatter stringFromDate:self.datePicker.date]];
    }
    
    
    [self.shineSwitch setOn:[JASettings shine]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)shineSwitchChanged:(id)sender
{
    if ([self.shineSwitch isOn] && ![JASettings stayAwake]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Whoops!", nil) message:NSLocalizedString(@"In order to turn on the Rise & Shine feature we'll have to disable autolock.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
        [alert setTag:0];
        [alert show];
    }
    else {
        [JASettings setShine:[self.shineSwitch isOn]];
    }
}


#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 200.0f;
    }
    
    return 40.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 && self.timeComponents != nil) {
        return 65.0f;
    }
    
    return 0.0f;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200.0f)];
        [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [headerView addSubview:self.sleepWakeControl];
        [headerView addSubview:self.timeButton];
        [headerView addSubview:self.sleepLabel];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30.0, 30.0f)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:[UIColor colorWithRed:59.0/255.0 green:67.0/255.0 blue:90.0/255.0 alpha:1.0]];
        [label setShadowColor:[UIColor whiteColor]];
        [label setShadowOffset:CGSizeMake(0, 1)];
        [label setText:NSLocalizedString(@"Sleep Cycle Calculator", nil)];
        [headerView addSubview:label];
        
        return headerView;
    }
    
    return nil;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && self.timeComponents != nil) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 65.0f)];
        [footerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [footerView addSubview:self.createButton];
        
        
        return footerView;
    }
    
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? NSLocalizedString(@"White Noise Sleep Timer", nil) : (section == 1) ? nil : NSLocalizedString(@"Rise & Shine", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        if (self.timeComponents == nil)
            return 0;
        else
            return 10;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            cell.textLabel.text = NSLocalizedString(@"Sleep Sound", nil);
            cell.detailTextLabel.text = [[self.sounds objectAtIndex:_selectedSound] objectForKey:@"name"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        }
        else if (indexPath.row == 1) {
            
            cell.textLabel.text = NSLocalizedString(@"Set Timer", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i %@", _selectedTime, NSLocalizedString(@"minutes", nil), nil];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        }
    }
    else if (indexPath.section == 1) {
        
        if (self.sleepWakeControl.selectedSegmentIndex == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        int timeInterval = -(60 * 90) * (10 - indexPath.row);
        NSDate *newDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:self.datePicker.date];
        
        cell.textLabel.text = [_formatter stringFromDate:newDate];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.detailTextLabel.text = @"";
    }
    else if (indexPath.section == 2) {

        cell.textLabel.text = NSLocalizedString(@"Rise & Shine", nil);
        cell.detailTextLabel.text = @"";
        cell.accessoryView = self.shineSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        _selectedPicker = indexPath.row;
        
        if (indexPath.row == 0) {
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:_selectedSound inComponent:0 animated:NO];
            [self raisePicker];
        }
        else {
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:((_selectedTime / 5) - 1) inComponent:0 animated:NO];
            [self raisePicker];
        }
    }
    else if (indexPath.section == 1)
    {
        self.createButton.enabled = YES;
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    
}



- (void) raisePicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - self.pickerView.frame.size.height);
                         self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                         self.pickerView.frame = CGRectMake(0, self.view.frame.size.height - self.pickerView.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) lowerPicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height);
                         self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 95, 0);
                         self.pickerView.frame = CGRectMake(0, self.view.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


#pragma mark - PickerView Delegate
- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_selectedPicker == 0)
        return self.sounds.count;
    else
        return 24;

}

- (int) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_selectedPicker == 0)
        return [[self.sounds objectAtIndex:row] objectForKey:@"name"];
    else
        return [NSString stringWithFormat:@"%i mins", (row + 1) * 5];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_selectedPicker == 0) {
        
        [JASettings setSleepSound:[self.sounds objectAtIndex:row]];
        _selectedSound = row;
        
    }
    else {
        
        _selectedTime = (row + 1) * 5;
        
        [JASettings setSnoozeLength:_selectedTime];
        
    }
    
    [self.tableView reloadData];
    [self lowerPicker];
}

#pragma mark - UIAlertviewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            [self.shineSwitch setOn:NO];
        }
        else {
            [self.shineSwitch setOn:YES];
            
            [JASettings setStayAwake:YES];
            [JASettings setShine:YES];
        }
    }
    else {
        if (buttonIndex == 1) {
            
            [self.shineSwitch setOn:NO];
            
            [JASettings setStayAwake:NO];
            [JASettings setShine:NO];
        }
    }
}


#pragma mark - Date Picker
- (void) togglePicker
{
    if (self.dateToolbar.frame.origin.y < self.view.frame.size.height) {
        [self lowerDatePicker];
    }
    else {
        [self raiseDatePicker];
    }
    
}

- (void) raiseDatePicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.dateToolbar.frame = CGRectMake(0, self.view.frame.size.height - self.datePicker.frame.size.height - self.dateToolbar.frame.size.height, self.view.frame.size.width, self.dateToolbar.frame.size.height);
                         self.datePicker.frame = CGRectMake(0, self.view.frame.size.height - self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) lowerDatePicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.dateToolbar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.dateToolbar.frame.size.height);
                         self.datePicker.frame = CGRectMake(0, self.view.frame.size.height + self.dateToolbar.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    
}

#pragma mark - Sleep Calc
- (void) createButtonPressed:(id)sender
{
    JAAlarm *_alarm = [[JAAlarm alloc] init];
    _alarm.alarmID = [NSNumber numberWithInt:-1];
    _alarm.enabled = YES;
    _alarm.gradualSound = YES;
    _alarm.repeatDays = [[NSArray alloc] init];
    _alarm.sound = [JASound defaultSound];
    _alarm.name = @"Sleep Smart Alarm";
    _alarm.snoozeTime = [NSNumber numberWithInt:10];
    _alarm.lastFireDate = nil;
    _alarm.enabledDate = [NSDate date];
    
    //time comps
    NSDate *alarmDate;
    if (self.sleepWakeControl.selectedSegmentIndex == 0) {
        alarmDate = self.datePicker.date;
    }
    else {
        int timeInterval = -(60 * 90) * (10 - [self.tableView indexPathForSelectedRow].row);
        alarmDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:self.datePicker.date];
    }
    
    //set time components
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:alarmDate];
    [timeComponents setSecond:0];
    _alarm.timeComponents = timeComponents;
    
    
    //Alarm Settings View
    JAAlarmSettingsController *newAlarmController =[[JAAlarmSettingsController alloc] initWithAlarm:_alarm];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    [saveButton setTitle:NSLocalizedString(@"Save", nil)];
    [newAlarmController.navigationItem setLeftBarButtonItem:saveButton];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newAlarmController];
    [self presentViewController:navController animated:YES completion:nil];
    
    
}

//set the alarm's date
- (void)dateChanged:(id)sender
{
    self.tableView.alpha = 1;
    
    if (self.sleepWakeControl.selectedSegmentIndex == 0) {
        
        
        //break the chosen date down so we just have the hour and minute with a zero'd seconds
        NSDate *theTime = self.datePicker.date;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:theTime];
        [timeComponents setSecond:0];
        
        //set time button label
        [self.timeButton setTitle:[_formatter stringFromDate:theTime] forState:UIControlStateNormal];
        
        //set the alarm's date
        self.timeComponents = timeComponents;
        
        //enable create buton
        [self.createButton setEnabled:YES];
    }
    else {
        
        //break the chosen date down so we just have the hour and minute with a zero'd seconds
        NSDate *theTime = self.datePicker.date;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:theTime];
        [timeComponents setSecond:0];
        
        //set the alarm's date
        self.timeComponents = timeComponents;
        
        //set time button label
        [self.timeButton setTitle:[_formatter stringFromDate:theTime] forState:UIControlStateNormal];
        
    }
    
    //reload times table
    [self.tableView reloadData];
}

- (void)controlChanged:(id)sender
{
    if (self.sleepWakeControl.selectedSegmentIndex == 0) {
        self.sleepLabel.text = NSLocalizedString(@"You try to fall asleep at one of these times:", nil);
        self.createButton.enabled = YES;
    }
    else {
        self.sleepLabel.text = NSLocalizedString(@"Select one of these times to wake up at:", nil);
        self.createButton.enabled = NO;
    }
    
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
}


@end