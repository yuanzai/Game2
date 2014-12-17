//
//  Transfer.m
//  Game2
//
//  Created by Junyuan Lau on 16/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "Transfer.h"
#import "GlobalVariableModel.h"
#import "Player.h"

@implementation Negotiation
@synthesize playerID, thisPlayer, lastBid, bidThreshold, bidRange, expiryWeek, responseWeek, counterparties, transferType;

- (id) initWithPlayer:(Player*)p
         TransferType:(TransferChoices) type
                  Bid:(NSInteger) bid
      CurrentWeekDate:(NSInteger) wkDate{
    self = [super init];
    if (self) {
        thisPlayer = p;
        playerID = p.PlayerID;
        if 
        
    } return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.playerID = [decoder decodeIntegerForKey:@"playerID"];
    self.lastBid = [decoder decodeIntegerForKey:@"lastBid"];
    self.bidThreshold = [decoder decodeIntegerForKey:@"bidThreshold"];
    self.bidRange = [decoder decodeObjectForKey:@"bidRange"];
    self.expiryWeek = [decoder decodeIntegerForKey:@"expiryWeek"];
    self.responseWeek = [decoder decodeIntegerForKey:@"responseWeek"];
    self.counterparties = [decoder decodeObjectForKey:@"counterparties"];
    self.transferType = (TransferChoices){[decoder decodeIntegerForKey:@"transferType"]};
    GlobalVariableModel* globals = [GlobalVariableModel myGlobalVariable];
    self.thisPlayer = [globals getPlayerFromID:self.playerID];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.playerID forKey:@"playerID"];
    [encoder encodeInteger:self.lastBid forKey:@"lastBid"];
    [encoder encodeInteger:self.bidThreshold forKey:@"bidThreshold"];
    [encoder encodeObject:self.bidRange forKey:@"bidRange"];
    [encoder encodeInteger:self.expiryWeek forKey:@"expiryWeek"];
    [encoder encodeInteger:self.responseWeek forKey:@"responseWeek"];
    [encoder encodeInteger:self.transferType forKey:@"transferType"];
    [encoder encodeObject:self.counterparties forKey:@"counterparties"];
}

- (Player*)thisPlayer
{
    if (!thisPlayer)
        thisPlayer = [[GlobalVariableModel myGlobalVariable]getPlayerFromID:self.playerID];
    return thisPlayer;
}



@end

@implementation Transfer
@synthesize negotiations;


- (id) init
{
    self = [super init];
    if (self) {

    }; return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.negotiations = [decoder decodeObjectForKey:@"negotiations"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.negotiations forKey:@"negotiations"];
}
@end
