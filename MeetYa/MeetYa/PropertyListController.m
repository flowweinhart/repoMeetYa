//
//  PropertyListController.m
//  MeetYa
//
//  Created by Flow Weinhart on 21/06/14.
//  Copyright (c) 2014 LMU. All rights reserved.
//

#import "PropertyListController.h"

@implementation PropertyListController

@synthesize sportrequests, currentSportReq;

-(void)createNewRequest:(NSString*)arg_person andTask:(NSString*)arg_task{
    NSDictionary *request = [[NSDictionary alloc] initWithObjectsAndKeys:arg_person, @"person", arg_task, @"task", nil];
    [sportrequests addObject:request];
    
    // TODO update view
    [self writeRequestsToFile];
}

-(void)updateRequest:(NSString*)arg_person andTask:(NSString*)arg_task{
    NSMutableDictionary *request = [[NSMutableDictionary alloc] initWithDictionary:[sportrequests objectAtIndex:currentSportReq]];
    [request setObject:arg_person forKey:@"person"];
    [request setObject:arg_task forKey:@"task"];
    [sportrequests replaceObjectAtIndex:currentSportReq withObject:request];
    
    // TODO update view
    [self writeRequestsToFile];
    currentSportReq = nil;
    
}

-(void)deleteRequestWithIndex:(NSInteger)arg_index{
    
    [sportrequests removeObjectAtIndex:arg_index];
    [self writeRequestsToFile];
    
}


-(void)writeRequestsToFile{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:@"PLIST_sportrequests.plist"];
    
    [sportrequests writeToFile:plistPath atomically:YES];
    
}

@end
