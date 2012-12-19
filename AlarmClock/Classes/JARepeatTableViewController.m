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
        self.title = NSLocalizedString(@"Repeat", nil);
        
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
                cell.textLabel.text = NSLocalizedString(@"Never", nil);
                cell.accessoryType = (self.alarm.repeatDays.count == 0) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Everyday", nil);
                cell.accessoryType = (self.alarm.repeatDays.count == 7) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Weekdays", nil);
                cell.accessoryType = ([JAAlarm justWeekdays:self.alarm.repeatDays]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Weekends", nil);
                cell.accessoryType = ([JAAlarm justWeekends:self.alarm.repeatDays]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
                
            default:
                break;
        }
        
    }
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Monday", nil);
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Tuesday", nil);
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Wednesday", nil);
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Thursday", nil);
                break;
            case 4:
                cell.textLabel.text = NSLocalizedString(@"Friday", nil);
                break;
            case 5:
                cell.textLabel.text = NSLocalizedString(@"Saturday", nil);
                break;
            case 6:
                cell.textLabel.text = NSLocalizedString(@"Sunday", nil);
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
                [newRepeateDays addObjectsFromArray:[NSArray arrayWithObjects:NSLocalizedString(@"Monday", nil), NSLocalizedString(@"Tuesday", nil), NSLocalizedString(@"Wednesday", nil), NSLocalizedString(@"Thursday", nil), NSLocalizedString(@"Friday", nil), NSLocalizedString(@"Saturday", nil), NSLocalizedString(@"Sunday", nil), nil]];
                break;
            case 2:
                [newRepeateDays removeAllObjects];
                [newRepeateDays addObjectsFromArray:[NSArray arrayWithObjects:NSLocalizedString(@"Monday", nil), NSLocalizedString(@"Tuesday", nil), NSLocalizedString(@"Wednesday", nil), NSLocalizedString(@"Thursday", nil), NSLocalizedString(@"Friday", nil), nil]];
                break;
            case 3:
                [newRepeateDays removeAllObjects];
                [newRepeateDays addObjectsFromArray:[NSArray arrayWithObjects:NSLocalizedString(@"Saturday", nil), NSLocalizedString(@"Sunday", nil), nil]];
                break;
                
            default:
                break;
        }
        
    }
    else {
        switch (indexPath.row) {
            case 0:
                if ([JAAlarm days:newRepeateDays containsDay:NSLocalizedString(@"Monday", nil)])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:NSLocalizedString(@"Monday", nil)]];
                else
                    [newRepeateDays addObject:NSLocalizedString(@"Monday", nil)];
                break;
            case 1:
                if ([JAAlarm days:newRepeateDays containsDay:NSLocalizedString(@"Tuesday", nil)])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:NSLocalizedString(@"Tuesday", nil)]];
                else
                    [newRepeateDays addObject:NSLocalizedString(@"Tuesday", nil)];
                
                break;
            case 2:
                if ([JAAlarm days:newRepeateDays containsDay:NSLocalizedString(@"Wednesday", nil)])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:NSLocalizedString(@"Wednesday", nil)]];
                else
                    [newRepeateDays addObject:NSLocalizedString(@"Wednesday", nil)];

                break;
            case 3:
                if ([JAAlarm days:newRepeateDays containsDay:NSLocalizedString(@"Thursday", nil)])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:NSLocalizedString(@"Thursday", nil)]];
                else
                    [newRepeateDays addObject:NSLocalizedString(@"Thursday", nil)];
                
                break;
            case 4:
                if ([JAAlarm days:newRepeateDays containsDay:NSLocalizedString(@"Friday", nil)])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:NSLocalizedString(@"Friday", nil)]];
                else
                    [newRepeateDays addObject:NSLocalizedString(@"Friday", nil)];

                break;
            case 5:
                if ([JAAlarm days:newRepeateDays containsDay:NSLocalizedString(@"Saturday", nil)])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:NSLocalizedString(@"Saturday", nil)]];
                else
                    [newRepeateDays addObject:NSLocalizedString(@"Saturday", nil)];

                break;
            case 6:
                if ([JAAlarm days:newRepeateDays containsDay:NSLocalizedString(@"Sunday", nil)])
                    newRepeateDays = [[NSMutableArray alloc] initWithArray:[JAAlarm days:newRepeateDays AfterRemovingDay:NSLocalizedString(@"Sunday", nil)]];
                else
                    [newRepeateDays addObject:NSLocalizedString(@"Sunday", nil)];

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
