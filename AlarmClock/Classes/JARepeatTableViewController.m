//
//  JARepeatTableViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/21/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JARepeatTableViewController.h"
#import "JAAlarm.h"

@interface JARepeatTableViewController ()

@end

@implementation JARepeatTableViewController

@synthesize repeatDays, alarm, delegate;

- (id)initWithAlarm:(JAAlarm*)theAlarm
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        
        self.alarm = theAlarm;
        self.repeatDays = [[NSMutableArray alloc] initWithArray:theAlarm.repeatDays];
        self.title = @"Repeat";
        
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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [JAAlarm saveAlarm:self.alarm];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (section == 0) ? 4 : 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Never";
                cell.accessoryType = (self.alarm.repeatDays.count == 0) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 1:
                cell.textLabel.text = @"Everyday";
                cell.accessoryType = (self.alarm.repeatDays.count == 7) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 2:
                cell.textLabel.text = @"Weekdays";
                cell.accessoryType = ([JAAlarm justWeekdays:self.alarm.repeatDays]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 3:
                cell.textLabel.text = @"Weekends";
                cell.accessoryType = ([JAAlarm justWeekends:self.alarm.repeatDays]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
                
            default:
                break;
        }
        
    }
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Monday";
                break;
            case 1:
                cell.textLabel.text = @"Tuesday";
                break;
            case 2:
                cell.textLabel.text = @"Wednesday";
                break;
            case 3:
                cell.textLabel.text = @"Thursday";
                break;
            case 4:
                cell.textLabel.text = @"Friday";
                break;
            case 5:
                cell.textLabel.text = @"Saturday";
                break;
            case 6:
                cell.textLabel.text = @"Sunday";
                break;
                
            default:
                break;
        }
        
        cell.accessoryType = ([JAAlarm days:self.alarm.repeatDays containsDay:[cell.textLabel.text lowercaseString]]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
    
    NSMutableArray *newRepeateDays = [[NSMutableArray alloc] initWithArray:self.alarm.repeatDays];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [newRepeateDays removeAllObjects];
                break;
            case 1:
                [newRepeateDays removeAllObjects];
                [newRepeateDays addObjectsFromArray:[NSArray arrayWithObjects:@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", @"sunday", nil]];
                break;
            case 2:
                [newRepeateDays removeAllObjects];
                [newRepeateDays addObjectsFromArray:[NSArray arrayWithObjects:@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", nil]];
                break;
            case 3:
                [newRepeateDays removeAllObjects];
                [newRepeateDays addObjectsFromArray:[NSArray arrayWithObjects:@"saturday", @"sunday", nil]];
                break;
                
            default:
                break;
        }
        
    }
    else {
        switch (indexPath.row) {
            case 0:
                if ([JAAlarm days:newRepeateDays containsDay:@"monday"])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:@"monday"]];
                else
                    [newRepeateDays addObject:@"monday"];
                break;
            case 1:
                if ([JAAlarm days:newRepeateDays containsDay:@"tuesday"])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:@"tuesday"]];
                else
                    [newRepeateDays addObject:@"tuesday"];
                
                break;
            case 2:
                if ([JAAlarm days:newRepeateDays containsDay:@"wednesday"])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:@"wednesday"]];
                else
                    [newRepeateDays addObject:@"wednesday"];

                break;
            case 3:
                if ([JAAlarm days:newRepeateDays containsDay:@"thursday"])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:@"thursday"]];
                else
                    [newRepeateDays addObject:@"thursday"];
                
                break;
            case 4:
                if ([JAAlarm days:newRepeateDays containsDay:@"friday"])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:@"friday"]];
                else
                    [newRepeateDays addObject:@"friday"];

                break;
            case 5:
                if ([JAAlarm days:newRepeateDays containsDay:@"saturday"])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:@"saturday"]];
                else
                    [newRepeateDays addObject:@"saturday"];

                break;
            case 6:
                if ([JAAlarm days:newRepeateDays containsDay:@"sunday"])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:@"sunday"]];
                else
                    [newRepeateDays addObject:@"sunday"];

                break;
                
            default:
                break;
        }
    
    }

    if (self.delegate && [(id)self.delegate respondsToSelector:@selector(repeatTableViewController:choseDays:)])
        [self.delegate repeatTableViewController:self choseDays:newRepeateDays];
    
    [self.alarm setRepeatDays:newRepeateDays];
    [self.tableView reloadData];

}

@end
