//
//  Transfer.h
//  Game2
//
//  Created by Junyuan Lau on 16/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;

typedef enum {
    TransferBuy,
    TransferSell
} TransferChoices;

typedef enum {
    TransferAccepted,
    TransferNegotiate,
    TransferRejected,
    TransferRejectedEndSeason,
    TransferRejectedSmallTeam
    
} TransferResponse;

/*
 Buying
 6 levels of pricing
 offer level 3 at start. if level = threshold, can buy the player
 */
@interface Negotiation : NSObject <NSCoding>

@property NSInteger playerID;
@property (nonatomic, strong) Player* thisPlayer;

@property NSInteger lastBid;
@property NSInteger bidThreshold;
@property NSMutableArray* bidRange;

@property NSInteger expiryWeek;
@property NSInteger responseWeek;
@property TransferResponse response;


@property NSMutableArray* counterparties;

@property TransferChoices transferType;

@property __block NSInteger playerRank;

+ (NSInteger) getPlayerSellingPriceWithPlayer:(Player*)p;


@end

@interface Transfer : NSObject <NSCoding>
@property NSMutableDictionary* negotiations;
@end
