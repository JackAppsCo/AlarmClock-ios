//
//  JABackgroundPickerViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JABackgroundPickerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JASettings.h"
#import "UIImage+fixOrientation.h"
#import "Flurry.h"


@interface JABackgroundPickerViewController ()
- (void) customImageTapped:(id)sender;

@end

@implementation JABackgroundPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //setup the dictionary from Settings.plist

        
    }
    return self;
}

- (void) setSelectedBG:(NSString*)bgName
{
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
                                                  
    for (NSDictionary *thisBG in self.backgroundList) {
        
        if (![[thisBG objectForKey:@"name"] isEqualToString:bgName]) {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.scrollView.frame.size.width, 0)];
        }
        else {
            break;
        }
        
    }
}

- (void) customImageTapped:(id)sender {

    if (![JASettings isPaid]) {
        //show nag
        [Flurry logEvent:@"Nag Screen Opened"];
        UIAlertView *freeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Like What You See?\nDon’t Like That You Can’t Use It?", nil) message:NSLocalizedString(@"…Then UPGRADE to SleepSmart Pro!\n\n⇒ Full access to ALL Background Themes!\n⇒ Full access to ALL White Noise Sleep Timer Themes!\n⇒ Full access to ALL Gentle Rise and Alarm Sounds!\n⇒ Unlock the “Rise & Shine” feature to emulate the sun!", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No Thanks", nil) otherButtonTitles:NSLocalizedString(@"Upgrade Me!", nil), nil];
        [freeAlert show];
        
        
    }
    else {
        UIActionSheet *imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo", @"Camera roll", nil];
        [imageActionSheet showInView:self.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Background Image", nil);
    // Do any additional setup after loading the view from its nib.
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.backgroundList) {
        NSString *bgsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"backgroundsList.plist"];
        NSDictionary *bgsDict = [[NSDictionary alloc] initWithContentsOfFile:bgsLocation];
        [self setBackgroundList:[bgsDict objectForKey:@"backgrounds"]];
        
        [self.scrollView setFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, self.view.frame.size.height - 45)];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * (self.backgroundList.count + 1), self.scrollView.frame.size.height)];
        
        CGRect currentFrame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
        for (NSDictionary *thisBG in self.backgroundList) {
            
            NSString *bgName = NSLocalizedString([thisBG objectForKey:@"name"], nil);
            NSString *bgFilename = [thisBG objectForKey:@"filename"];

            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectInset(currentFrame, 5, 10)];
            [img setImage:[UIImage imageNamed:bgFilename]];
            //[img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Sample.png", [bgFilename stringByReplacingOccurrencesOfString:@".png" withString:@""], nil]]];
            [img setClipsToBounds:YES];
            [img setContentMode:UIViewContentModeScaleAspectFill];
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x, img.frame.origin.y + img.frame.size.height + 10, img.frame.size.width, 45.0f)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont fontWithName:TITLE_FONT size:19.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [lbl setShadowOffset:CGSizeMake(0, 1)];
            [lbl setShadowColor:[UIColor darkTextColor]];
            [lbl setText:bgName];
            
            if (![JASettings isPaid] && ![[thisBG objectForKey:@"free"] boolValue]) {
                [img.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0.5].CGColor];
                [img.layer setBorderWidth:img.frame.size.width];
                [lbl setTextColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
            }
            
            UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
            [done setFrame:CGRectInset(img.frame, 0, 0)];
            [done addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.scrollView addSubview:img];
            [self.scrollView addSubview:lbl];
            [self.scrollView addSubview:done];
            
            currentFrame = CGRectOffset(currentFrame, currentFrame.size.width, 0);
            
        }
        
        NSString *customName = @"Custom";
        NSString *bgFilename = @"";
        
        //check to see if there's already been an image chosen
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"customBG.png"]; //Add the file name]
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        
        //setup custom image
        self.customImage = [[UIImageView alloc] initWithFrame:CGRectInset(currentFrame, 5, 10)];
        [self.customImage setClipsToBounds:YES];
        [self.customImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.customImage.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.customImage.layer setBorderWidth:3.0f];
        
        self.customImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect btnFrame = CGRectInset(self.customImage.frame, 0, 25.0);
        btnFrame.origin.y = 0;
        [self.customImageButton setFrame:btnFrame];
        
        //user custom if if found
        if (pngData) {
            [self.customImage setImage:[UIImage imageWithData:pngData]];
            [self setCustomImageURL:@"custom"];
            [self.customImageButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [self.customImage setImage:[UIImage imageNamed:bgFilename]];
            [self.customImageButton addTarget:self action:@selector(customImageTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [plusButton setFrame:CGRectMake(self.customImage.frame.origin.x, self.customImage.frame.origin.y + self.customImage.frame.size.height - 50, self.customImage.frame.size.width, 50)];
        [plusButton addTarget:self action:@selector(customImageTapped:) forControlEvents:UIControlEventTouchUpInside];
        [plusButton setImage:[UIImage imageNamed:@"customBGIcon.png"] forState:UIControlStateNormal];
        [plusButton setTitle:NSLocalizedString(@"Create You Own", nil) forState:UIControlStateNormal];
        [plusButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
        [plusButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [plusButton.layer setBorderWidth:3.0f];
        [plusButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [plusButton setTitleColor:[UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [plusButton setImageEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
        [plusButton.titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:18]];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.customImage.frame.origin.x, self.customImage.frame.origin.y + self.customImage.frame.size.height + 10, self.customImage.frame.size.width, 45.0f)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setFont:[UIFont fontWithName:TITLE_FONT size:19.0f]];
        [lbl setTextColor:([JASettings isPaid]) ? [UIColor whiteColor] : [UIColor colorWithWhite:0.7 alpha:1.0]];
        [lbl setShadowOffset:CGSizeMake(0, 1)];
        [lbl setShadowColor:[UIColor darkTextColor]];
        [lbl setText:customName];
        
        [self.scrollView addSubview:self.customImage];
        [self.scrollView addSubview:lbl];
        [self.scrollView addSubview:plusButton];
        [self.scrollView addSubview:self.customImageButton];
        

        
        [self setSelectedBG:[JASettings backgroundImageName]];
        
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //dismiss the picker view
    [self dismissModalViewControllerAnimated:YES];
    
    // Get the image from the result
    self.customImageURL = @"custom";
    UIImage *originalImage = [[info valueForKey:@"UIImagePickerControllerOriginalImage"] fixOrientation];
    UIImage *imageCropped = [self imageByCropping:originalImage toRect:[[info valueForKey:@"UIImagePickerControllerCropRect"] CGRectValue]];
    //imageCropped.imageOrientation = [(UIImage*)[info valueForKey:@"UIImagePickerControllerOriginalImage"] imageOrientation];
    [self.customImage setImage:imageCropped];
    
    NSData *pngData = UIImagePNGRepresentation([self.customImage.image fixOrientation]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"customBG.png"]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
    [self.customImageButton removeTarget:self action:@selector(customImageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.customImageButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    
    return cropped;
    
}

#pragma mark - UIActionSheet Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
            
        case 0:
        {
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            [imgPicker setAllowsEditing:YES];
            imgPicker.delegate = self;
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:imgPicker animated:YES];
            break;
        }
        case 1:
        {
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [imgPicker setAllowsEditing:YES];            
            imgPicker.delegate = self;
            [self presentModalViewController:imgPicker animated:YES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    
    float offset = self.scrollView.contentOffset.x;
    int page = offset / self.scrollView.frame.size.width;

    if (![JASettings isPaid] && ![[[self.backgroundList objectAtIndex:page] objectForKey:@"free"] boolValue]) {
        //show nag
        [Flurry logEvent:@"Nag Screen Opened"];
        UIAlertView *freeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Like What You See?\nDon’t Like That You Can’t Use It?", nil) message:NSLocalizedString(@"…Then UPGRADE to SleepSmart Pro!\n\n⇒ Full access to ALL Background Themes!\n⇒ Full access to ALL White Noise Sleep Timer Themes!\n⇒ Full access to ALL Gentle Rise and Alarm Sounds!\n⇒ Unlock the “Rise & Shine” feature to emulate the sun!", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No Thanks", nil) otherButtonTitles:NSLocalizedString(@"Upgrade Me!", nil), nil];
        [freeAlert show];
        
        
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIAlertviewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        [Flurry logEvent:@"App Store Opened"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"APPSTORE_URL_PAID", nil)]];
    }
    
}

@end
