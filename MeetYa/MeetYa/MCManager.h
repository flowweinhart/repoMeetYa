//
//  MCManager.h
//  MCDemo
//
//  Created by Benedikt Reschberger on 05/06/14.
//  Copyright (c) 2014 PEM2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCPeerID *partnerPeerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) NSData * ownImageData;

@property BOOL recievedInvitation;
@property BOOL sendInvitation;
@property BOOL inSession;

@property BOOL matchAccepted;
@property BOOL pictureRecieved;

@property BOOL mcEnabled;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;

-(void) setupMCBrowser;
-(void) startBrowser;
-(void) stopBrowser;

-(void) setupMCAdvertiserWithDiscoveryInfo:(NSDictionary *) info;
-(void) startAdvertiser;
-(void) stopAdvertiser;

-(void)advertiseSelf:(BOOL)shouldAdvertise;

-(void)sendResponse:(BOOL)acceptedMatch;

-(void) createDataImage:(UIImage *) image;


@end
