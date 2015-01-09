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
#import "Team.h"
#import "Fixture.h"
@implementation Negotiation
@synthesize playerID, thisPlayer, lastBid, bidThreshold, bidRange, expiryWeek, responseWeek, counterparties, transferType, response;

/*
 
 bid
 done/reject/renego
 
 buy/sell/for sale
 1-6
 6 - 90%2/95%2/99%1/99%1/100%1  / 200%
 5 - 66%2/80%2/95%1/99%1/100%1  / 160%
 4 - 10%3/33%3/66%2/75%2/100%2  / 140%
 3 - 0%3/5%3/33%3/66%2/100%2  / 120%
 2 - 0%3/0%3/10%3/50%3/75%2  / 100%
 1 - 0%3/0%3/0%3/33%3/50%2  / 75%
 
 top/impt/team/squad
 
 
 bid
 cannot be smaller
 lasts till end of season/next season if end of season
 1 chance per bid
 
 ****selling****
 news - get 5/6 offers only
 for sale starts at 1
 
 
 */
- (id) initBuyWithPlayer:(Player*)p
         TransferType:(TransferChoices) type
                  Bid:(NSInteger) bid
      CurrentWeekDate:(NSInteger) wkDate{
    self = [super init];
    if (self) {
        thisPlayer = p;
        playerID = p.PlayerID;
        lastBid = bid;
        
        GlobalVariableModel* globals = [GlobalVariableModel myGlobalVariable];
        Team* thisTeam = [globals getTeamFromID:p.TeamID];
        __block NSInteger playerRank;
        NSInteger lastWeekDate = thisTeam.leagueTournament.lastWeekDate;
        
        [[thisTeam getAllPlayersSortByValuation]enumerateObjectsUsingBlock:^(Player* arrayPlayer, NSUInteger idx, BOOL *stop) {
            
            if (thisPlayer.PlayerID == arrayPlayer.PlayerID) {
                playerRank = idx;
                *stop = YES;
            }
        }];
        
        transferType = TransferBuy;
        if (playerRank < 4) {
            playerRank = 1;
            if (wkDate <= lastWeekDate) {
                responseWeek = wkDate + 1;
                response = TransferRejectedEndSeason;
            } else {
                if (bid <5 ){
                 responseWeek = wkDate + 3;
                } else {
                 responseWeek = wkDate + 2;
                }
            }
        } else if (playerRank < 9) {
         playerRank = 2;
            if (wkDate <= lastWeekDate || bid < 6) {
                responseWeek = wkDate + 1;
                response = TransferRejectedEndSeason;
            } else {
                if (bid <5 ){
                 responseWeek = wkDate + 3;
                } else {
                 responseWeek = wkDate + 2;
                }
            }
        } else if (playerRank < 16) {
         playerRank = 3;
            if (wkDate <= lastWeekDate || bid < 5) {
                responseWeek = wkDate + 1;
                response = TransferRejectedEndSeason;
            } else {
                if (bid <4 ){
                 responseWeek = wkDate + 3;
                } else if (bid <5 ) {
                 responseWeek = wkDate + 2;
                } else {
                 responseWeek = wkDate + 1;
                }
            }
        } else {
         playerRank = 4;
            if (wkDate <= lastWeekDate || bid < 4) {
                responseWeek = wkDate + 1;
                response = TransferRejectedEndSeason;
            } else {
                if (bid <5 ){
                    responseWeek = wkDate + 2;
                } else {
                    responseWeek = wkDate + 1;
                }
            }
        }
        
        if (response != TransferRejectedEndSeason) {
            
            NSInteger prob = [self getProbabilityForBid:bid Rank:playerRank];
            
            if (arc4random() % 100 < prob) {
                response = TransferAccepted;
            } else {
                response = TransferRejected;
            }
            if ([thisTeam.PlayerList count]<20) {
                response = TransferRejectedSmallTeam;
                responseWeek = wkDate + 1;
            }
        }
    } return self;
}

- (NSInteger) getProbabilityForBid:(NSInteger) bid Rank:(NSInteger) rank
{
    NSArray* prob = @[@"",@[@"",@(0),@(0),@(0),@(33),@(50)]
                      ,@[@"",@(0),@(0),@(0),@(50),@(75)]
                      ,@[@"",@(0),@(5),@(33),@(66),@(100)]
                      ,@[@"",@(10),@(33),@(66),@(75),@(100)]
                      ,@[@"",@(60),@(80),@(95),@(99),@(100)]
                      ,@[@"",@(90),@(95),@(99),@(99),@(100)]];
    
    return [prob[rank][bid] integerValue];

}

- (void) cancelBid
{
}

- (void) negotiateBid:(NSInteger) bid CurrentWeekDate:(NSInteger) wkDate{

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

- (Negotiation*) getNegotiationForPlayer:(Player*) p
{
    for (Negotiation* neg in self.negotiations) {
        if (neg.playerID == p.PlayerID)
            return neg;
    }
    return nil;
}
@end
