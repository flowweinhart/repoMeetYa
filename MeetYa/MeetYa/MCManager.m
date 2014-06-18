//
//  MCManager.m
//  MCDemo
//
//  Created by Benedikt Reschberger on 05/06/14.
//  Copyright (c) 2014 PEM2014. All rights reserved.
//

#import "MCManager.h"
#import "Request.h"
#import "AppDelegate.h"

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

-(void) sendResponse:(BOOL)acceptedMatch{
    NSData * data = [[NSData alloc] init];
    if(acceptedMatch){
        data = [[NSData alloc] initWithBase64EncodedString:@"MatchAccepted" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    else{
        data = [[NSData alloc] initWithBase64EncodedString:@"MatchDeclined" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    
    NSError *error;
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    NSLog(@"Send Data to Peers");
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if(acceptedMatch) //TODO
        [self sendPicture];
}

-(void) sendPicture{
    //TODO Absoluter Pfadangabe für das Bild -> woher? bzw. NSData Objekt bereits beim öffnen der App erstellen
    NSData * data = nil;
    // AppDelegate * appD = [[UIApplication sharedApplication] delegate];
    //TODO data = appD.pictureData
    NSError *error;
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    NSLog(@"Send Picture");
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

// Session Delegate Methoden
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
    
    if(state == MCSessionStateConnected)
        NSLog([@"Did change State to Connected: " stringByAppendingString:peerID.displayName]);
    else if (state == MCSessionStateConnecting){
        NSLog([@"Did change State to Connecting: " stringByAppendingString:peerID.displayName]);
    }
    
    
    if(state == MCSessionStateConnected && ![_peerID isEqual:peerID] && _recievedInvitation){
        [self sendPicture];
    }
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog([@"didReceiveDataFrom: " stringByAppendingString:peerID.displayName]);
    
    //TODO Bild von Person A anzeigen, falls data ein Bild ist
    //TODO falls Data ein "match accepted" ist, 1. auf Bild warten oder 2. Match anzeigen
    if([data isKindOfClass:[NSString class]]){
        NSString * d = (NSString *) data;
        if([d isEqualToString:@"MatchAccepted"] && _matchAccepted){
            //TODO showMatch
            NSLog(@"Show match");
        }
        else if([d isEqualToString:@"MatchAccepted"] && !_matchAccepted){
            //TODO sendPicture
            NSLog(@"Send picture");
            NSData * data = [[NSData alloc] initWithBase64EncodedString:@"sendPicturePls" options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSError * error;
            [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
        else if([d isEqualToString:@"MatchDeclined"]){
            //TODO showNoMatchWasFound
            NSLog(@"Show no match was found");
        }
    }
    else if([data isKindOfClass:[UIImage class]]){
        NSLog(@"recieved Image");
    }
    
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
//  [_advertiser stopAdvertisingPeer];
    
    
    //TODO showDialog
    [self acceptInvite:true invitationHandler:invitationHandler];
    
    /*
     if(false){
        _session = [[MCSession alloc] initWithPeer:_peerID];
        _session.delegate = self;
        NSLog(@"Session created");
    
        invitationHandler(true, _session);
        NSLog([@"Accepted Invitation from Peer: " stringByAppendingString: peerID.displayName]);
    }
    */
    
}

-(void) acceptInvite:(BOOL) accepted invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
   
        _session = [[MCSession alloc] initWithPeer:_peerID];
        _session.delegate = self;
        NSLog(@"Session created");
        
        invitationHandler(accepted, _session);
        NSLog(@"Accepted Invitation");
    
}

// Wird aufgerufen wenn ein Peer gefunden wurde
-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    //TODO
    NSLog([@"Found Peer: " stringByAppendingString: peerID.displayName]);
    
    if([self matching:info]){
        float t = (arc4random() % 100 + 1.0) / 100.0;
        t = t * 2;
        NSTimeInterval delayInSeconds = t;
        NSLog([@"Time waited before invitation: " stringByAppendingString:[NSString stringWithFormat:@"%f",t]]);
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if(!_recievedInvitation){
                //TODO context = NSData = Bild der eigenen Person
                [_browser invitePeer:peerID toSession:_session withContext:nil timeout:10];
                
                NSLog([@"Send Invitation to Peer " stringByAppendingString: peerID.displayName]);
            }
        });
    }
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

-(void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"@", [error localizedDescription]);
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



-(BOOL) matching:(NSDictionary *) dic {
    AppDelegate * appD = [[UIApplication sharedApplication] delegate];
    
    NSLog(@"Processing Match...");
    
	for(Request * req in appD.requests){
		NSString * key 	= req.task;
		NSString * value= (NSString *)[dic valueForKey:key];
        
        NSLog([@"Processing for: " stringByAppendingString:key]);
		if( ([key isEqualToString:@"Anything"] && [self anythingMatches:dic WithPerson:req.person])
           || (value != nil && [self value:value matchesValue:req.person]))
        {
			[self matchFoundForRequest:req];
            return true;
		}
	}
    return false;
}

-(void) matchFoundForRequest:(Request *) req {
    NSString * log = [@"Found Task: " stringByAppendingString: req.task];
    [log stringByAppendingString:@"  Found Person: "];
    [log stringByAppendingString:req.person];
    NSLog(log);
}

-(BOOL) anythingMatches:(NSDictionary *) dic WithPerson:(NSString *) value{
	NSArray * values = [dic allValues]; //TODO
	for(NSString * v in values){
		if([self value:v matchesValue:value]) return true;
	}
	return false;
}

-(BOOL) value:(NSString *) v1 matchesValue:(NSString *) v2{
    NSLog([[v1 stringByAppendingString:@" matches "] stringByAppendingString:v2]);
	if([v2 isEqualToString:@"Anyone"]) {return true;}
	else {
        if([v1 isEqualToString:@"Anyone"]){return true;}
        else if ([v1 isEqualToString:@"Peer"] && [v2 isEqualToString:@"Peer"]){return true;}
        else if ([v1 isEqualToString:@"Trainer"] && [v2 isEqualToString:@"Student"]){return true;}
        else if ([v1 isEqualToString:@"Student"] && [v2 isEqualToString:@"Trainer"]){return true;}
    }
    return false;
}


@end
