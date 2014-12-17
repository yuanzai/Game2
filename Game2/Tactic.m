//
//  TacticsModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 29/04/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "Tactic.h"
#import "GameModel.h"
#import "Player.h"

@implementation TacticPosition
@synthesize ps;
@synthesize player;
@synthesize PositionID;

@end

@implementation Tactic
{
    NSMutableDictionary* dataPlayerList;
}
@synthesize TacticID;
@synthesize GoalKeeper;
@synthesize SubList;
@synthesize positionArray;

- (id)initWithTacticID:(NSInteger) InputID WithPlayerDict:(NSMutableDictionary*) playerList
{
    self = [super init];
    if (self) {
        if (TacticID ==0)
            dataPlayerList = playerList;
        TacticID = InputID;
        SubList = [NSMutableArray array];
        positionArray = [NSMutableArray array];
        NSArray* formationData = [[GameModel myDB]getArrayFrom:@"tactics" whereKeyField:@"TACTICID" hasKey:[NSNumber numberWithInteger:InputID] sortFieldAsc:@""];
        
        [formationData enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            TacticPosition* tp = [TacticPosition new];
            tp.PositionID = idx;
            tp.ps = (PositionSide) {[[obj objectForKey:@"POSITIONVAL"]integerValue],[[obj objectForKey:@"SIDEVAL"]integerValue]};
            if (playerList) {
                if ([playerList objectForKey:[@(idx) stringValue]])
                    tp.player = [[[GlobalVariableModel myGlobalVariable] playerList]objectForKey:[[playerList objectForKey:[@(idx) stringValue]]stringValue]];
            }
            formationArray[[[obj objectForKey:@"POSITIONVAL"]integerValue]][[[obj objectForKey:@"SIDEVAL"]integerValue]] = tp;
            [positionArray addObject:tp];
        }];
        if (playerList) {
            if ([playerList objectForKey:@"GK"])
                GoalKeeper = [[[GlobalVariableModel myGlobalVariable] playerList]objectForKey:[[playerList objectForKey:@"GK"]stringValue]];
            
            for (NSInteger i = 0; i < 7; i++) {
                if ([playerList objectForKey:[NSString stringWithFormat:@"SUB%i",i]]) {
                    [SubList addObject:[[[GlobalVariableModel myGlobalVariable] playerList]objectForKey:[[playerList objectForKey:[NSString stringWithFormat:@"SUB%i",i]]stringValue]]];
                }
            }
        }
    } return self;
}

- (NSArray*) getOutFieldPositions
{
    NSMutableArray* result = [NSMutableArray array];
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (formationArray[i][j])
                [result addObject:formationArray[i][j]];
        }
    };
    return result;
}


- (NSArray*) getOutFieldPlayers
{
    NSMutableArray* result = [NSMutableArray array];
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (formationArray[i][j].player)
                [result addObject:formationArray[i][j].player];
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

- (TacticPosition*) getTacticPositionAtPositionSide:(PositionSide) ps
{
    return formationArray[ps.position][ps.side];
}


- (Player*) getPlayerAtPositionSide:(PositionSide) ps
{
    return formationArray[ps.position][ps.side].player;
}

- (BOOL) hasPlayerAtPositionSide:(PositionSide) ps
{
    if(formationArray[ps.position][ps.side].player)
        return YES;
    return NO;
}


- (BOOL) populatePlayer:(Player*) player PositionSide:(PositionSide) ps ForceSwap:(BOOL) swap
{
    if (ps.side == GKSide) {
        GoalKeeper = player;
        return YES;
    }

    
    if (![self hasPositionAtPositionSide:ps])
        return NO;
    if (formationArray[ps.position][ps.side].player && formationArray[ps.position][ps.side].player.PlayerID == player.PlayerID)
        return YES;
    
    [self removePlayerFromTactic:player];
    formationArray[ps.position][ps.side].player = player;

    return YES;
}

- (BOOL) removePlayerAtPositionSide:(PositionSide) ps
{
    if (!formationArray[ps.position][ps.side])
        return NO;
    if (!formationArray[ps.position][ps.side].player)
        return YES;
    formationArray[ps.position][ps.side].player = nil;
    return YES;
}

- (void) removePlayerFromTactic : (Player*) player
{
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (formationArray[i][j]) {
                if (formationArray[i][j].player.PlayerID == player.PlayerID)
                    formationArray[i][j].player = nil;
            }
        }
    }
    [SubList enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.PlayerID == player.PlayerID)
            [SubList removeObjectAtIndex:idx];
    }];
    if (GoalKeeper.PlayerID == player.PlayerID)
        GoalKeeper = nil;
}


- (BOOL) moveTacticPositionAtPositionSide:(PositionSide) fromPS ToPositionSide:(PositionSide) toPS
{
    if (!formationArray[fromPS.position][fromPS.side])
        return NO;
    
    TacticPosition* tempTP;
    tempTP = formationArray[fromPS.position][fromPS.side];
    formationArray[fromPS.position][fromPS.side] = formationArray[toPS.position][toPS.side];
    formationArray[toPS.position][toPS.side] = tempTP;
    
    formationArray[toPS.position][toPS.side].ps = toPS;

    if (formationArray[fromPS.position][fromPS.side])
        formationArray[fromPS.position][fromPS.side].ps = fromPS;
    
    return YES;
}

- (void) validateTactic
{
    if (GoalKeeper.isInjured)
        GoalKeeper = nil;
    [positionArray enumerateObjectsUsingBlock:^(TacticPosition* tp, NSUInteger idx, BOOL *stop) {
        if (tp.player.isInjured)
            tp.player = nil;
    }];
}


- (BOOL) isTacticValid
{
    __block BOOL result = YES;
    
    [positionArray enumerateObjectsUsingBlock:^(TacticPosition* tp, NSUInteger idx, BOOL *stop) {
        if (!tp.player) {
            *stop = YES;
            result = NO;
        }
    }];
    if (!GoalKeeper)
        result = NO;

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
    if (formationArray[ps.position][ps.side])
        return YES;
    return NO;
}

- (BOOL) updateTacticsInDatabase
{
    NSInteger PositionID = 1;
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            if (PositionID > 9)
                return NO;
            if (formationArray[i][j]) {
                [[GameModel myDB]updateDatabaseTable:@"tactics" whereDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@(TacticID),@"TACTICID",@(PositionID),@"PLAYER", nil] setDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@(i),@"POSITIONVAL",@(j),@"SIDEVAL", nil]];
                PositionID++;
            }
        }
    }
    return YES;
}

- (BOOL) updatePlayerLineup
{
    [dataPlayerList removeAllObjects];
    [dataPlayerList setObject:@(GoalKeeper.PlayerID) forKey:@"GK"];
    [[self getOutFieldPositions] enumerateObjectsUsingBlock:^(TacticPosition* tp, NSUInteger idx, BOOL *stop) {
        [dataPlayerList setObject:@(tp.player.PlayerID) forKey:[@(tp.PositionID) stringValue]];
    }];
    
    [SubList enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        [dataPlayerList setObject:@(p.PlayerID) forKey:[NSString stringWithFormat:@"SUB%lu",(unsigned long)idx]];
    }];
    
    return YES;
}

@end
