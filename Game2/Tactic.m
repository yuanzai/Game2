//
//  TacticsModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 29/04/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "Tactic.h"
#import "DatabaseModel.h"

@implementation Tactic
@synthesize TacticID;
@synthesize GoalKeeper;
@synthesize SubList;

- (id)initWithTacticID:(NSInteger) InputID;
{
    self = [super init];
    if (self) {
        TacticID = InputID;
        NSArray* formationData = [[[DatabaseModel alloc]init]getArrayFrom:@"tactics" whereKeyField:@"TacticID" hasKey:[NSNumber numberWithInteger:InputID] sortFieldAsc:@""];
        [formationData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            formationArray[[[obj objectForKey:@"PositionVal"]integerValue]][[[obj objectForKey:@"SideVal"]integerValue]] = YES;
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

- (BOOL) populatePlayer:(Player*) player Position:(PositionChoices)position Side:(SideChoices)side
{
    if (!formationArray[position][side])
        return NO;
    playerArray[position][side] = player;
    return YES;
}

- (Player*) getPlayerAtPosition:(PositionChoices)position Side:(SideChoices)side
{
    if (!formationArray[position][side]) {
        playerArray[position][side] = nil;
        return nil;
    }
    return playerArray[position][side];
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
    return formationArray[ps.position][ps.side];
}


- (BOOL) movePlayerAtPosition:(PositionChoices)fromposition AtSide:(SideChoices)fromside ToPosition:(PositionChoices)toposition ToSide:(SideChoices)toside
{
    if (!formationArray[fromposition][fromside] && !formationArray[toposition][toside])
        return NO;

    Player* temp;
    BOOL tempBool;
    temp = playerArray[fromposition][fromside];
    playerArray[fromposition][fromside] = playerArray[toposition][toside];
    playerArray[toposition][toside] = temp;
    
    tempBool = formationArray[fromposition][fromside];
    formationArray[fromposition][fromside] = formationArray[toposition][toside];
    formationArray[toposition][toside] = tempBool;
    return YES;
}

- (BOOL) updateTacticsInDatabase
{
    //TODO
    return YES;
}
@end
