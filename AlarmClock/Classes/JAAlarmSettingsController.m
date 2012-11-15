//
//  JAAlarmSettingsController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAAlarmSettingsController.h"

@interface JAAlarmSettingsController ()
- (void)dateChanged:(id)sender;

@end

@implementation JAAlarmSettingsController

@synthesize alarm = _alarm, tableView = _tableView, datePicker = _datePicker;

- (id)initWithAlarm:(JAAlarm*)anAlarm
{
    self = [super init];
    if (self) {
        // Custom initialization
        if (anAlarm)
            _alarm = anAlarm;
        else {
            _alarm = [[JAAlarm alloc] init];
            _alarm.alarmID = [NSNumber numberWithInt:-1];
            
            NSDate *now = [NSDate dateWithTimeIntervalSinceNow:(60 * 10)];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now];
            [timeComponents setSecond:0];
            
            _alarm.timeComponents = timeComponents;
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker setDate:[NSDate dateWithTimeInterval:(60 * 10) sinceDate:[NSDate date]]];
    [_datePicker setDatePickerMode:UIDatePickerModeTime];
    [_datePicker setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [_datePicker setFrame:CGRectOffset(_datePicker.frame, 0, self.view.frame.size.height - _datePicker.frame.size.height)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - _datePicker.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    [self.view addSubview:_datePicker];    
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [JAAlarm saveAlarm:self.alarm];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i:%02i%@", (_alarm.timeComponents.hour > 12) ? _alarm.timeComponents.hour - 12 : (_alarm.timeComponents.hour == 0) ? 12 : _alarm.timeComponents.hour, _alarm.timeComponents.minute, (_alarm.timeComponents.hour > 12) ? @"pm" : @"am", nil];
    cell.textLabel.text = @"Time";
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
