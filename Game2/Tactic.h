//
//  TacticsModel.h
//  MatchEngine
//
//  Created by Junyuan Lau on 29/04/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"

@class Player;
@class Tactic;
@interface TacticPosition : NSObject
@property PositionSide ps;
@property Player* player;
@property NSInteger PositionID;

@end

@interface Tactic : NSObject
{    
    __block TacticPosition* formationArray[5][5];
}
@property NSInteger TacticID;
@property __block NSMutableArray* positionArray;
@property Player* GoalKeeper;
@property NSMutableArray* SubList;

- (NSArray*) getOutFieldPlayers;
- (NSArray*) getAllPlayers;

- (id)initWithTacticID:(NSInteger) InputID WithPlayerDict:(NSMutableDictionary*) playerList;

- (BOOL) populatePlayer:(Player*) player PositionSide:(PositionSide) ps ForceSwap:(BOOL) swap;
- (BOOL) removePlayerAtPositionSide:(PositionSide) ps;
- (void) removePlayerFromTactic : (Player*) player;
- (BOOL) moveTacticPositionAtPositionSide:(PositionSide) fromPS ToPositionSide:(PositionSide) toPS;

- (TacticPosition*) getTacticPositionAtPositionSide:(PositionSide) ps;
- (Player*) getPlayerAtPositionSide:(PositionSide) ps;
- (BOOL) hasPlayerAtPositionSide:(PositionSide) ps;
- (BOOL) hasPositionAtPositionSide: (PositionSide) ps;

- (BOOL) isFormationFilled;

- (BOOL) updateTacticsInDatabase;
- (BOOL) updatePlayerLineup;

@end
