//
//  TacticsModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 29/04/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "Tactic.h"
#import "GameModel.h"
#import "DatabaseModel.h"
#import "Player.h"
@implementation TacticPosition
@synthesize ps;
@synthesize player;
@synthesize PositionID;

@end

@implementation Tactic
@synthesize TacticID;
@synthesize GoalKeeper;
@synthesize SubList;

- (id)initWithTacticID:(NSInteger) InputID;
{
    self = [super init];
    if (self) {

        TacticID = InputID;
        NSArray* formationData = [[GameModel myDB]getArrayFrom:@"tactics" whereKeyField:@"TACTICID" hasKey:[NSNumber numberWithInteger:InputID] sortFieldAsc:@""];
        [formationData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            formationArray[[[obj objectForKey:@"POSITIONVAL"]integerValue]][[[obj objectForKey:@"SIDEVAL"]integerValue]] = YES;
        }];
    } return self;
}

- (NSArray*) getOutFieldPlayers
{
    NSMutableArray* result = [NSMutableArray array];
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (playerArray[i][j])
                [result addObject:playerArray[i][j]];
                
        }
    };
    return result;
}

- (NSArray*) getAllPlayers
{
    NSMutableArray* result = [[NSMutableArray alloc]initWithArray:[self getOutFieldPlayers]];
    [result addObject:GoalKeeper];
    return result;
}

- (Player*) getPlayerAtPositionSide:(PositionSide) ps
{
    if (!formationArray[ps.position][ps.side]) {
        playerArray[ps.position][ps.side] = nil;
        return nil;
    }
    return playerArray[ps.position][ps.side];
}

- (BOOL) hasPlayerAtPositionSide:(PositionSide) ps
{
    if (!playerArray[ps.position][ps.side])
        return NO;
    return YES;
}


- (BOOL) populatePlayer:(Player*) player PositionSide:(PositionSide) ps ForceSwap:(BOOL) swap
{
    if (!formationArray[ps.position][ps.side])
        return NO;
    if (playerArray[ps.position][ps.side].PlayerID == player.PlayerID)
        return YES;
    
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (playerArray[i][j]) {
                if (playerArray[i][j].PlayerID == player.PlayerID) {
                    if (swap) {
                        return [self movePlayerAtPositionSide:(PositionSide){i,j} ToPositionSide:ps];
                    } else {
                        return NO;
                    }
                }
            }
        }
    };

    playerArray[ps.position][ps.side] = player;
    return YES;
}

- (BOOL) removePlayerAtPositionSide:(PositionSide) ps
{
    if (!formationArray[ps.position][ps.side])
        return NO;
    playerArray[ps.position][ps.side] = nil;
    return YES;
}

- (void) removePlayerFromTactic : (Player*) player
{
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (playerArray[i][j]) {
                if (playerArray[i][j].PlayerID == player.PlayerID)
                    playerArray[i][j] = nil;
            }
        }
    }
}


- (BOOL) movePlayerAtPositionSide:(PositionSide) fromPS ToPositionSide:(PositionSide) toPS
{
    if (!formationArray[fromPS.position][fromPS.side] && !formationArray[toPS.position][toPS.side])
        return NO;

    Player* temp;
    BOOL tempBool;
    temp = playerArray[fromPS.position][fromPS.side];
    playerArray[fromPS.position][fromPS.side] = playerArray[toPS.position][toPS.side];
    playerArray[toPS.position][toPS.side] = temp;
    
    tempBool = formationArray[fromPS.position][fromPS.side];
    formationArray[fromPS.position][fromPS.side] = formationArray[toPS.position][toPS.side];
    formationArray[toPS.position][toPS.side] = tempBool;
    return YES;
}

- (BOOL) isFormationFilled
{
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (formationArray[i][j]){
                PositionSide ps;
                ps.side = i;
                ps.position = j;
                if (![self hasPlayerAtPositionSide:ps]){
                    return NO;
                }
            }
        }
    };
    return YES;
}

- (BOOL) hasPositionAtPositionSide: (PositionSide) ps
{
    return formationArray[ps.position][ps.side];
}

- (BOOL) updateTacticsInDatabase
{
    //TODO
    return YES;
}


@end
