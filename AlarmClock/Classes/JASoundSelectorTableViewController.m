//
//  JASoundSelectorTableViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/17/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASoundSelectorTableViewController.h"
#import "VoiceRecordViewController.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface JASoundSelectorTableViewController ()
- (IBAction)showMediaPicker:(id)sender;
@end

@implementation JASoundSelectorTableViewController

@synthesize delegate, soundList, selectedSound;

- (id)initWithDelegate:(id <JASoundSelectorTableViewControllerDelegate>)theDelegate
{
    return [self initWithDelegate:theDelegate sound:nil];
}

- (id)initWithDelegate:(id <JASoundSelectorTableViewControllerDelegate>)theDelegate sound:(JASound*)aSound
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        [self setDelegate:theDelegate];
        
        //setup the dictionary from Settings.plist
		NSString *soundsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"soundsList.plist"];
		NSDictionary *soundsDict = [[NSDictionary alloc] initWithContentsOfFile:soundsLocation];
        [self setSoundList:[soundsDict objectForKey:@"sounds"]];
        
        //set the selected sound
        if (!aSound) {
            JASound *newSound = [[JASound alloc] init];
            [newSound setName:@"Alarm"];
            [newSound setSoundFilename:@"alarm.mp3"];
            [self setSelectedSound:newSound];
        }
        else {
            [self setSelectedSound:aSound];
        }
            
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Alarm Sound";
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return self.soundList.count;
    else if (section == 1)
        return (1 + [JASound savedSounds].count);
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SoundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        // Configure the cell...
        cell.textLabel.text = [(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        if ([[(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"filename"] isEqualToString:self.selectedSound.soundFilename]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Record A New Sound";
        }
        else {
            cell.textLabel.text = [(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] name];
            
            if ([[(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] soundFilename] isEqualToString:self.selectedSound.soundFilename]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else {
        if (self.selectedSound.collection) {
            cell.textLabel.text = [[self.selectedSound.collection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.textLabel.text = @"Choose From Library";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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
    
    JASound *newSound = nil;
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            VoiceRecordViewController *recorder = [[VoiceRecordViewController alloc] initWithNibName:@"VoiceRecordViewController" bundle:[NSBundle mainBundle]];
            [self presentModalViewController:recorder animated:YES];
            [recorder.cancelButton setTarget:self];
            [recorder.cancelButton setAction:@selector(dismissModalViewControllerAnimated:)];
        }
        else {
            
            [self setSelectedSound:(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)]];
            
            newSound = [[JASound savedSounds] objectAtIndex:(indexPath.row - 1)];            
            
        }
        
    }
    else if (indexPath.section == 0) {
        
        newSound = [[JASound alloc] init];
        [newSound setName:[(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"name"]];
        [newSound setSoundFilename:[(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"filename"]];
        [self setSelectedSound:newSound];
    }
    else {
        [self showMediaPicker:nil];
    }
    
    [self.tableView reloadData];
    
    if (newSound && self.delegate && [(id)self.delegate respondsToSelector:@selector(soundSelectorTableViewController:choseSound:)]) {
        [self.delegate soundSelectorTableViewController:self choseSound:newSound];
    }
}


// Configures and displays the media item picker.
- (IBAction) showMediaPicker: (id) sender {
    
	MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= NO;
    picker.showsCloudItems              = NO;
    
	[self presentModalViewController:picker animated:YES];
	
}


// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {

    if (mediaItemCollection.count > 0) {
        
        JASound *newSound = [[JASound alloc] init];
        newSound.name = [[[mediaItemCollection items] objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
        newSound.soundFilename = [[[mediaItemCollection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyAssetURL] absoluteString];
        MPMediaItem *item = [mediaItemCollection.items objectAtIndex:0];
        NSLog(@"URL: %@", [item valueForProperty:MPMediaItemPropertyAssetURL]);
        newSound.collection = mediaItemCollection;
        self.selectedSound = newSound;
        
        if (newSound && self.delegate && [(id)self.delegate respondsToSelector:@selector(soundSelectorTableViewController:choseSound:)]) {
            [self.delegate soundSelectorTableViewController:self choseSound:newSound];
        }
    }
    
    [self.tableView reloadData];
	[self dismissModalViewControllerAnimated: YES];

    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [self.tableView reloadData];
	[self dismissModalViewControllerAnimated: YES];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


@end
