//
//  MCManager.m
//  MCDemo
//
//  Created by Benedikt Reschberger on 05/06/14.
//  Copyright (c) 2014 PEM2014. All rights reserved.
//

#import "MCManager.h"

@implementation MCManager


-(id)init{
    self = [super init];
    
    if (self) {
        _peerID = nil;
        _session = nil;
        _browser = nil;
        _advertiser = nil;
    }
    
    return self;
}


// Session Delegate Methoden
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSLog([@"Did change State: " stringByAppendingString:peerID.displayName]);
    
    if(state == MCSessionStateConnected){
    NSString * log = @"Session: ";
    for(MCPeerID * i in _session.connectedPeers){
        [log stringByAppendingString:i.displayName];
        [log stringByAppendingString:@" , "];
    }
    NSLog(log);
    
    NSTimeInterval delayInSeconds = (arc4random() % 100 + 1) / 100;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSData * data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        NSLog(@"Send Data to Peers");
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    });
    }
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"didReceiveData");
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

//MCNearbyServiceAdvertiserDelegate Methoden
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
    NSLog([@"Recieved Invitation from Peer: " stringByAppendingString: peerID.displayName]);
    _recievedInvitation = true;
    if(_recievedInvitation){
        NSLog(@"recievedInvitation = TRUE ");
    }
    [_browser stopBrowsingForPeers];
    NSLog(@"Browser stoped");
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    NSLog(@"Session created");
    
    invitationHandler(true, _session);
    NSLog([@"Accepted Invitation from Peer: " stringByAppendingString: peerID.displayName]);
    
}

// Wird aufgerufen wenn ein Peer gefunden wurde
-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    NSLog([@"Found Peer: " stringByAppendingString: peerID.displayName]);
    
    //TODO if([self match:info])
    
    
    float t = (arc4random() % 100 + 1.0) / 100.0;
    NSTimeInterval delayInSeconds = t;
    NSLog([@"Time waited before invitation: " stringByAppendingString:[NSString stringWithFormat:@"%f",t]]);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(!_recievedInvitation){
            [_browser invitePeer:peerID toSession:_session withContext:nil timeout:10];
            NSLog([@"Send Invitation to Peer " stringByAppendingString: peerID.displayName]);
        }
    });
}

// Wird aufgerufen wenn ein gefundener Peer wird verloren wurde
-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    NSLog([@"Lost Peer: " stringByAppendingString: peerID.displayName]);
    
    //TODO
    /*
      evtl. neuer Bildschirm mit Infos, dass Peer nicht gefunden wurde
     */
}

// Browser wird gestartet und sucht nach Peers, falls Peer gefunden => browser:foundPeer:withDiscoveryInfo:
// falls Peer verloren => browser:lostPeer:
-(void)setupMCBrowser{
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:@"MeetYa"];
    NSLog(@"Browser Setup");
}


// Starte und Stope den Browser, evtl. zeitlich abhägig wegen Stromverbrauch
-(void) startBrowser{
    if(_browser != nil){
        [_browser startBrowsingForPeers]; // <- Stromverbrauch ??
        [_browser setDelegate:self];
        NSLog(@"Browser Sarted");
    }
}

-(void) stopBrowser{
    [_browser stopBrowsingForPeers];
    NSLog(@"Browser Stoped");
}


// Advertiser bietet sich an um von anderen Peers gefunden zu werden
-(void) setupMCAdvertiserWithDiscoveryInfo:(NSDictionary *)info{
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:info serviceType:@"MeetYa"];
    NSLog(@"Advertiser Setup");
}


// Starte / Stope den Advertiser ->
-(void) startAdvertiser{
    if(_advertiser != nil){
        [_advertiser startAdvertisingPeer];
        [_advertiser setDelegate:self];
        NSLog(@"Advertiser Sarted");
    }
}

-(void) stopAdvertiser{
    [_advertiser stopAdvertisingPeer];
    _advertiser = nil;
    NSLog(@"Advertiser Stoped");
}


// selfmade Methoden
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName{
    _peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    NSLog(@"Peer and Session Setup");
}

-(void)advertiseSelf:(BOOL)shouldAdvertise{
    if (shouldAdvertise) {
        [self setupMCAdvertiserWithDiscoveryInfo:nil];
        [self startAdvertiser];
    }
    else{
        [self stopAdvertiser];
    }
}




@end
