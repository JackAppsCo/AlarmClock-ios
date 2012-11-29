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

@interface JABackgroundPickerViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];

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
            
            NSString *bgName = [thisBG objectForKey:@"name"];
            NSString *bgFilename = [thisBG objectForKey:@"filename"];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectInset(currentFrame, 5, 10)];
            [img setImage:[UIImage imageNamed:bgFilename]];
            [img setClipsToBounds:YES];
            [img setContentMode:UIViewContentModeScaleAspectFill];
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x, img.frame.origin.y + img.frame.size.height + 10, img.frame.size.width, 45.0f)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [lbl setShadowOffset:CGSizeMake(0, 1)];
            [lbl setShadowColor:[UIColor darkTextColor]];
            [lbl setText:bgName];
            
            [self.scrollView addSubview:img];
            [self.scrollView addSubview:lbl];
            
            currentFrame = CGRectOffset(currentFrame, currentFrame.size.width, 0);
            
        }
        
        NSString *customName = @"Custom";
        NSString *bgFilename = @"plus.png";
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectInset(currentFrame, 5, 10)];
        [img setImage:[UIImage imageNamed:bgFilename]];
        [img setClipsToBounds:YES];
        [img setContentMode:UIViewContentModeScaleAspectFill];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x, img.frame.origin.y + img.frame.size.height + 10, img.frame.size.width, 45.0f)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f]];
        [lbl setTextColor:[UIColor whiteColor]];
        [lbl setShadowOffset:CGSizeMake(0, 1)];
        [lbl setShadowColor:[UIColor darkTextColor]];
        [lbl setText:customName];
        
        [self.scrollView addSubview:img];
        [self.scrollView addSubview:lbl];
        
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
    [super viewDidUnload];
}
@end
