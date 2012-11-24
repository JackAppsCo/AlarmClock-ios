//
//  JABackgroundPickerViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JABackgroundPickerViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *bgsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"backgroundsList.plist"];
    NSDictionary *bgsDict = [[NSDictionary alloc] initWithContentsOfFile:bgsLocation];
    [self setBackgroundList:[bgsDict objectForKey:@"backgrounds"]];
    
    for (NSDictionary *thisBG in self.backgroundList) {
        NSString *bgName = [thisBG objectForKey:@"name"];
        NSString *bgFilename = [thisBG objectForKey:@"filename"];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.contentSize.width + 30, 30, 260, 260)];
        [img setFrame:CGRectOffset(img.frame, self.scrollView.contentSize.width, 0)];
        [img setImage:[UIImage imageNamed:bgFilename]];
        [img setClipsToBounds:YES];
        [img setContentMode:UIViewContentModeScaleAspectFill];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x, img.frame.origin.y + img.frame.size.height + 5, img.frame.size.width, 20.0f)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setFont:[UIFont fontWithName:@"Cochrin" size:19.0f]];
        [lbl setText:bgName];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width + self.scrollView.frame.size.width, self.scrollView.contentSize.height)];
        [self.scrollView addSubview:img];
        [self.scrollView addSubview:lbl];
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
