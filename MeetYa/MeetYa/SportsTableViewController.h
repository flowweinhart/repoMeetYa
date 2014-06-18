//
//  SportsTableViewController.h
//  MeetYa
//
//  Created by Flow Weinhart on 02/06/14.
//  Copyright (c) 2014 LMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SportsTableViewController : UITableViewController

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, weak) NSMutableArray *requests;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainSwitch;

- (IBAction)mainSwitchSwitched:(id)sender;

@end
