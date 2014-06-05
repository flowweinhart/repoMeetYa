//
//  RequestDetailViewController.h
//  MeetYa
//
//  Created by Flow Weinhart on 02/06/14.
//  Copyright (c) 2014 LMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"

@interface RequestDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (nonatomic, weak) Request *request;


@end
