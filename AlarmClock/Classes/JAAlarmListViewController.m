//
//  JAAlarmListViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAAlarmListViewController.h"
#import "JAAlarmSettingsController.h"

@interface JAAlarmListViewController ()
- (void) addAlarm;
- (void) closeSettings;
- (void) enableToggled:(id)sender;
@end

@implementation JAAlarmListViewController

@synthesize alarms = _alarms;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIBarButtonItem *addAlarmButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAlarm)];
        NSArray *rightButtons = [[NSArray alloc] initWithObjects:addAlarmButton, nil];
        [self.navigationItem setRightBarButtonItems:rightButtons];
        
        _alarms = [JAAlarm savedAlarms];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _alarms = [JAAlarm savedAlarms];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) enableToggled:(id)sender
{
    JAAlarm *thisAlarm = [_alarms objectAtIndex:[(UISwitch*)sender tag]];
    [thisAlarm setEnabled:[(UISwitch*)sender isOn]];
    [JAAlarm saveAlarm:thisAlarm];
    _alarms = [JAAlarm savedAlarms];
    [self.tableView reloadData];
}

- (void) closeSettings
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) addAlarm
{
    JAAlarmSettingsController *newAlarmController =[[JAAlarmSettingsController alloc] initWithAlarm:nil];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(closeSettings)];
    [closeButton setTitle:@"Save"];
    [newAlarmController.navigationItem setLeftBarButtonItem:closeButton];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newAlarmController];
    [self presentViewController:navController animated:YES completion:nil];
    
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _alarms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        UIImageView *whiteBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [whiteBG setImage:[UIImage imageNamed:@"alarmRowBG.png"]];
        cell.backgroundView = whiteBG;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
    }
    
    // Configure the cell...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    JAAlarm *thisAlarm = [_alarms objectAtIndex:indexPath.row];
    cell.textLabel.text = thisAlarm.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i:%02i%@", (thisAlarm.timeComponents.hour > 12) ? thisAlarm.timeComponents.hour - 12 : (thisAlarm.timeComponents.hour == 0) ? 12 : thisAlarm.timeComponents.hour, thisAlarm.timeComponents.minute, (thisAlarm.timeComponents.hour > 12) ? @"pm" : @"am", nil];
    
    
    UISwitch *enabledSwitch = [[UISwitch alloc] init];
    [enabledSwitch setOn:[thisAlarm enabled]];
    [enabledSwitch setTag:indexPath.row];
    [enabledSwitch addTarget:self action:@selector(enableToggled:) forControlEvents:UIControlEventValueChanged];
    [cell setAccessoryView: enabledSwitch];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        [JAAlarm removeAlarm:[_alarms objectAtIndex:indexPath.row]];
        _alarms = [JAAlarm savedAlarms];
        [self.tableView reloadData];
        

    }
}


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
    JAAlarmSettingsController *newAlarmController =[[JAAlarmSettingsController alloc] initWithAlarm:[_alarms objectAtIndex:indexPath.row]];
    newAlarmController.title = newAlarmController.alarm.name;
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.navigationController action:@selector(popViewControllerAnimated:)];
    [closeButton setTitle:@"Save"];
    [newAlarmController.navigationItem setBackBarButtonItem:closeButton];
    [newAlarmController setHidesBottomBarWhenPushed:YES];

    
    
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:newAlarmController animated:YES];
     
}

@end
