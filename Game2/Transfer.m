//
//  Transfer.m
//  Game2
//
//  Created by Junyuan Lau on 16/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "Transfer.h"
#import "GlobalVariableModel.h"
#import "GameModel.h"
#import "Player.h"
#import "Team.h"
#import "Fixture.h"
@implementation Negotiation

@synthesize playerID, thisPlayer, lastBid, bidThreshold, bidRange, expiryWeek, responseWeek, counterparties, transferType, response, playerRank;

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
 
 Bid
 Nego
 Sell
 ForSale
 Holdout
 
 */
- (id) initWithPlayer:(Player*)p
         CurrentWeekDate:(NSInteger) wkDate{
    self = [super init];
    if (self) {
        thisPlayer = p;
        playerID = p.PlayerID;
    } return self;
}

- (void) doStartBid:(NSInteger) bid
{
    NSInteger wkDate = [[[[GlobalVariableModel myGlobalVariable]myGame] myData]weekdate];
    
    lastBid = bid;
    
    Team* thisTeam = [thisPlayer getPlayerTeam];
    NSInteger lastWeekDate = thisTeam.leagueTournament.lastWeekDate;
    
    playerRank = [self getPlayerRankWithTeam:thisTeam Player:thisPlayer];
    transferType = TransferBuy;
    
    responseWeek = [self getResponseDelay] + wkDate;
    response = [self getResponse];
    
    // check season
    if (playerRank == 1) {
        if (wkDate <= lastWeekDate) {
            responseWeek = wkDate + 1;
            response = TransferRejectedEndSeason;
        }
    } else if (playerRank == 2) {
        if (wkDate <= lastWeekDate || bid < 6) {
            responseWeek = wkDate + 1;
            response = TransferRejectedEndSeason;
        }
    } else if (playerRank == 3) {
        if (wkDate <= lastWeekDate || bid < 5) {
            responseWeek = wkDate + 1;
            response = TransferRejectedEndSeason;
        }
    } else {
        if (wkDate <= lastWeekDate || bid < 4) {
            responseWeek = wkDate + 1;
            response = TransferRejectedEndSeason;
        }
    }
    
    // check team size
    if ([thisTeam.PlayerList count]<20) {
        response = TransferRejectedSmallTeam;
        responseWeek = wkDate + 1;
    }
}

- (void) doNegotiateBid:(NSInteger) bid
{
    if (bid <= lastBid)
        return;
    
    NSInteger wkDate = [[[[GlobalVariableModel myGlobalVariable]myGame] myData]weekdate];

    lastBid = bid;
    responseWeek = wkDate + [self getResponseDelay];
    response = [self getResponse];
    
    // check team size
    Team* thisTeam = [thisPlayer getPlayerTeam];
    if ([thisTeam.PlayerList count]<20) {
        response = TransferRejectedSmallTeam;
        responseWeek = wkDate + 1;
    }
}

- (void) doSell
{
    NSInteger wkDate = [[[[GlobalVariableModel myGlobalVariable]myGame] myData]weekdate];

    lastBid = [Negotiation getPlayerSellingPriceWithPlayer:thisPlayer];
    transferType = TransferSell;
    responseWeek = wkDate;
    response = TransferAccepted;
}

- (void) doForSale
{
    NSInteger wkDate = [[[[GlobalVariableModel myGlobalVariable]myGame] myData]weekdate];

    lastBid = [Negotiation getPlayerSellingPriceWithPlayer:thisPlayer];
    transferType = TransferSell;
    responseWeek = wkDate;
    
    NSInteger r1 = arc4random() % 10 ;
    NSInteger r2 = arc4random() % 4 + arc4random() % 2 ;

    if (thisPlayer.globalRank < 1) {
        if (r1 < 3) {
            lastBid += 2;
        } else {
            lastBid += 1;
        }
        responseWeek += r2 + 1;
        
    } else if (thisPlayer.globalRank < 10) {

        if (r1 < 2) {
            lastBid += 2;
        } else if (r1 < 8) {
            lastBid += 1;
        }
        responseWeek += r2 + 2;
    }  else if (thisPlayer.globalRank < 20) {
        
        if (r1 < 1) {
            lastBid += 2;
        } else if (r1 < 6) {
            lastBid += 1;
        }
        responseWeek += r2 + 2;
    } else if (thisPlayer.leagueRank < 15) {
        if (r1 < 3) {
            lastBid += 2;
        } else if (r1 < 9) {
            lastBid += 1;
        }
        responseWeek += r2 + 2;
    } else if (thisPlayer.leagueRank < 33) {
        if (r1 < 1) {
            lastBid += 2;
        } else if (r1 < 6) {
            lastBid += 1;
        }
        responseWeek += r2 + 2;
    } else {
        if (r1 < 5) {
            lastBid += 1;
        }
        responseWeek += r2 + 3;
    }
}

+ (NSInteger) getPlayerSellingPriceWithPlayer:(Player*)p
{
    NSInteger bid;
    
    if (p.globalRank < 10) {
        bid = 3;
    } else if (p.globalRank < 20) {
        bid = 2;
    } else if (p.globalRank < 50) {
        bid = 1;
    } else {
        bid = 0;
    }
    
    if (p.leagueRank< 20) {
        bid = MIN(bid + 2,3);
    } else if (p.leagueRank< 60) {
        bid = MIN(bid + 1,2);
    }
    
    return bid;
}

- (id) initForSaleWithPlayer:(Player*)p
          CurrentWeekDate:(NSInteger) wkDate{
    
    self = [super init];
    if (self) {
        thisPlayer = p;
        playerID = p.PlayerID;
        lastBid = [Negotiation getPlayerSellingPriceWithPlayer:p];
        transferType = TransferSell;
        responseWeek = wkDate;
        response = TransferAccepted;
    } return self;
}

- (void) negotiateSale:(NSInteger) bid
{
    
}


- (TransferResponse) getResponse
{
    NSArray* prob = @[@"",@[@"",@(0),@(0),@(0),@(33),@(50)]
                      ,@[@"",@(0),@(0),@(0),@(50),@(75)]
                      ,@[@"",@(0),@(5),@(33),@(66),@(100)]
                      ,@[@"",@(10),@(33),@(66),@(75),@(100)]
                      ,@[@"",@(60),@(80),@(95),@(99),@(100)]
                      ,@[@"",@(90),@(95),@(99),@(99),@(100)]];
    
    if (arc4random() % 100 < [prob[playerRank][lastBid] integerValue]) {
        return TransferAccepted;
    } else {
        return TransferRejected;
    }
}

- (NSInteger) getPlayerRankWithLeagueForPlayer:(Player*) p
{
    __block NSInteger rank;
    GlobalVariableModel* globals = [GlobalVariableModel myGlobalVariable];
    Team* thisTeam = [globals getTeamFromID:p.TeamID];
    NSMutableArray* playerArray = [NSMutableArray array];
    [thisTeam.leagueTournament.teamList enumerateObjectsUsingBlock:^(Team* t, NSUInteger idx, BOOL *stop) {
        [playerArray addObjectsFromArray:t.PlayerList];
    }];
    
    playerArray = [[NSMutableArray alloc]initWithArray:[playerArray sortedArrayUsingComparator:^NSComparisonResult(Player* a, Player* b) {
        return [@(b.Valuation) compare:@(a.Valuation)];
    }]];

    [[thisTeam getAllPlayersSortByValuation]enumerateObjectsUsingBlock:^(Player* arrayPlayer, NSUInteger idx, BOOL *stop) {
        
        if (p.PlayerID == arrayPlayer.PlayerID) {
            rank = idx;
            *stop = YES;
        }
    }];
    return (rank * 100)/[playerArray count];
}

- (NSInteger) getPlayerRankWithTeam:(Team*)thisTeam Player:(Player*) p
{
    __block NSInteger rank;
    [[thisTeam getAllPlayersSortByValuation]enumerateObjectsUsingBlock:^(Player* arrayPlayer, NSUInteger idx, BOOL *stop) {
        
        if (p.PlayerID == arrayPlayer.PlayerID) {
            rank = idx;
            *stop = YES;
        }
    }];
    if (rank < 4) {
        return 1;
    } else if (rank < 9) {
        return 2;
    } else if (rank < 16) {
        return 3;
    } else {
        return 4;
    }
}

- (void) acceptTransfer
{
}

- (void) cancelBid
{
    
}

- (NSInteger) getResponseDelay
{
    if (playerRank == 1) {
        if (lastBid <5 ){
            return 3;
        } else {
            return 2;
        }
        
    } else if (playerRank == 2) {
        
        if (lastBid <5 ){
            return 3;
        } else {
            return 2;
        }
        
    } else if (playerRank == 3) {
        if (lastBid <4 ){
            return 3;
        } else if (lastBid <5 ) {
            return 2;
        } else {
            return 1;
        }
        
    } else {
        if (lastBid <5 ){
            return 2;
        } else {
            return 1;
        }
    }
}

- (BOOL) isPendingResponseCurrentWeekDate:(NSInteger) currentWeek
{
    return (currentWeek < responseWeek);
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
    self.playerRank = [decoder decodeIntegerForKey:@"playerRank"];
    self.response = (TransferResponse){[decoder decodeIntegerForKey:@"response"]};
    
    
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
    [encoder encodeInteger:self.response forKey:@"response"];
    [encoder encodeInteger:self.playerRank forKey:@"playerRank"];
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
