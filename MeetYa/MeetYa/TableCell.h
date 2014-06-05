//
//  TableCell.h
//  MeetYa
//
//  Created by Flow Weinhart on 03/06/14.
//  Copyright (c) 2014 LMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *personLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskLabel;
@property (nonatomic, weak) IBOutlet UISwitch *cellSwitch;

@end
