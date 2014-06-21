//
//  PropertyListController.h
//  MeetYa
//
//  Created by Flow Weinhart on 21/06/14.
//  Copyright (c) 2014 LMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyListController : NSObject

@property (nonatomic, retain) NSMutableArray *sportrequests;
@property (nonatomic, assign) NSInteger currentSportReq;

-(void)writeRequestsToFile;

@end
