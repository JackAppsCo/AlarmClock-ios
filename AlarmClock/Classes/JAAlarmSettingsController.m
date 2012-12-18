//
//  JAAlarmSettingsController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAAlarmSettingsController.h"
#import "JARepeatTableViewController.h"


@interface JAAlarmSettingsController ()
- (void)saveAlarm:(id)sender;
- (void)cancelEdit:(id)sender;
@end

@implementation JAAlarmSettingsController

@synthesize alarm = _alarm, tableView = _tableView, datePicker = _datePicker, enableSwitch = _enableSwitch, gradualSwitch = _gradualSwitch, nameField = _nameField, snoozeField = _snoozeField;

- (id)initWithAlarm:(JAAlarm*)anAlarm
{
    self = [super init];
    if (self) {
        
        pressedCancel = NO;
        
        //init date
        NSDate *now;
        
        if (anAlarm) {
            _alarm = anAlarm;
        }
        else {
            _alarm = [[JAAlarm alloc] init];
            _alarm.alarmID = [NSNumber numberWithInt:-1];
            _alarm.enabled = YES;
            _alarm.gradualSound = YES;
            _alarm.repeatDays = [[NSArray alloc] init];
            _alarm.sound = [JASound defaultSound];
            _alarm.name = @"Alarm";
            _alarm.snoozeTime = [NSNumber numberWithInt:10];
            
            //time comps
            now = [NSDate dateWithTimeIntervalSinceNow:(60 * 10)];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now];
            [timeComponents setSecond:0];
            _alarm.timeComponents = timeComponents;

        }
        
        [self setEnableSwitch:[[UISwitch alloc] init]];
        [self.enableSwitch setOn:self.alarm.enabled];
        
        [self setGradualSwitch:[[UISwitch alloc] init]];
        [self.gradualSwitch setOn:self.alarm.gradualSound];
        
        [self setNameField:[[UITextField alloc] init]];
        self.nameField.frame = CGRectMake(0, 0, 200.0, 23.0);
        [self.nameField setTextAlignment:NSTextAlignmentRight];
        self.nameField.returnKeyType = UIReturnKeyDone;
        self.nameField.delegate = self;
        self.nameField.text = _alarm.name;
        self.nameField.textColor = [UIColor darkTextColor];
        
        [self setSnoozeField:[[UITextField alloc] init]];
        self.snoozeField.frame = CGRectMake(0, 0, 150.0, 23.0);
        [self.snoozeField setTextAlignment:NSTextAlignmentRight];
        self.snoozeField.returnKeyType = UIReturnKeyDone;
        self.snoozeField.keyboardType = UIKeyboardTypeNumberPad;
        self.snoozeField.delegate = self;
        self.snoozeField.text = [NSString stringWithFormat:@"%i", [_alarm.snoozeTime intValue], nil];
        self.snoozeField.textColor = [UIColor darkTextColor];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _datePicker = [[UIDatePicker alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [_datePicker setDate:[gregorian dateFromComponents:_alarm.timeComponents]];
    [_datePicker setDatePickerMode:UIDatePickerModeTime];
    [_datePicker setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [_datePicker setFrame:CGRectOffset(_datePicker.frame, 0, self.view.frame.size.height - _datePicker.frame.size.height)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - _datePicker.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    [self.view addSubview:_datePicker];    
 
    //if this is a new alarm set the buttons
    if (self.navigationController.viewControllers.count == 1) {

        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)]];
    
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelEdit:)]];
    }
    
    
}

- (void)cancelEdit:(id)sender
{
    pressedCancel = YES;
    [self dismissModalViewControllerAnimated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (!pressedCancel)
    {
        self.alarm.enabled = self.enableSwitch.on;
        self.alarm.gradualSound = self.gradualSwitch.on;
        self.alarm.name = self.nameField.text;
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.alarm.snoozeTime = [f numberFromString:self.snoozeField.text];
        [JAAlarm saveAlarm:self.alarm];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//set the alarm's date
- (void)dateChanged:(id)sender
{
    if (sender == _datePicker) {
        
        //break the chosen date down so we just have the hour and minute with a zero'd seconds
        NSDate *theTime = _datePicker.date;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:theTime];
        [timeComponents setSecond:0];

        //set the alarm's date
        _alarm.timeComponents = timeComponents;
        
        [_tableView reloadData];
    }
}

#pragma mark - Rotate  Methods
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    
    //figure out which cell
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Name", nil);
            cell.accessoryView = self.nameField;
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Time", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i:%02i%@", (_alarm.timeComponents.hour > 12) ? _alarm.timeComponents.hour - 12 : (_alarm.timeComponents.hour == 0) ? 12 : _alarm.timeComponents.hour, _alarm.timeComponents.minute, (_alarm.timeComponents.hour > 12) ? @"pm" : @"am", nil];
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Enabled", nil);
            cell.accessoryView = self.enableSwitch;
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Repeat", nil);
            cell.detailTextLabel.text = [JAAlarm labelForDays:self.alarm.repeatDays];
            break;
        case 4:
            cell.textLabel.text = NSLocalizedString(@"Sound", nil);
            cell.detailTextLabel.text = self.alarm.sound.name;
            break;
        case 5:
            cell.textLabel.text = NSLocalizedString(@"Gradual Alarm", nil);
            cell.accessoryView = self.gradualSwitch;
            break;
        case 6:
            cell.textLabel.text = NSLocalizedString(@"Snooze (mins)", nil);
            cell.accessoryView = self.snoozeField;
            break;
            
        default:
            break;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JARepeatTableViewController *repeatTableController = [[JARepeatTableViewController alloc] initWithAlarm:self.alarm];
    [repeatTableController setDelegate:self];
    
    //figure out which cell
    switch (indexPath.row) {
        case 0:
            [self.nameField becomeFirstResponder];
            [self.snoozeField resignFirstResponder];
            break;
        case 1:
            [self.nameField resignFirstResponder];
            [self.snoozeField resignFirstResponder];
            break;
        case 2:
            break;
        case 3:
            [self.navigationController pushViewController:repeatTableController animated:YES];
            break;
        case 4:
        {
            JASoundSelectorTableViewController *controller = [[JASoundSelectorTableViewController alloc] initWithDelegate:self sound:self.alarm.sound];
            [self.navigationController pushViewController:controller animated:YES];
            
            break;
        }
        case 5:
            break;
        case 6:
        {
            [self.nameField resignFirstResponder];
            [self.snoozeField becomeFirstResponder];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Text Field Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _nameField) {
        [self.nameField resignFirstResponder];
        self.alarm.name = textField.text;
    }
    else if (textField == _snoozeField) {
        [self.snoozeField resignFirstResponder];
        self.snoozeField.text = [NSString stringWithFormat:@"%i", [_alarm.snoozeTime intValue], nil];
    }
    return YES;
}

#pragma mark - Sound Delegate
- (void) soundSelectorTableViewController:(JASoundSelectorTableViewController *)controller choseSound:(JASound *)sound
{
    if (sound) {
        [self.alarm setSound:sound];
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - Repeat Delegate
- (void) repeatTableViewController:(JARepeatTableViewController *)controller choseDays:(NSArray *)days
{
    if (days) {
        [self.alarm setRepeatDays:days];
    }
    
    [self.tableView reloadData];
    
}


@end
