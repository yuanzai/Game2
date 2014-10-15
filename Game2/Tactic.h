//
//  TacticsModel.h
//  MatchEngine
//
//  Created by Junyuan Lau on 29/04/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;
typedef enum {
    Left,
    LeftCentre,
    Centre,
    RightCentre,
    Right,
    GKSide,
    SideCount
} SideChoices;

typedef enum {
    Def,
    DM,
    Mid,
    AM,
    SC,
    GKPosition,
    PositionCount
} PositionChoices;

struct PositionSide {
    PositionChoices position;
    SideChoices side;
};

typedef struct PositionSide PositionSide;

@interface Tactic : NSObject
{
    NSInteger TacticID;
    //NSString* name;
    
    BOOL formationArray[5][5];
    Player* playerArray[5][5];
    Player* GoalKeeper;
    NSArray* SubList;
}
@property NSInteger TacticID;
@property Player* GoalKeeper;
@property NSArray* SubList;

//@property NSString* name;
- (NSArray*) getOutFieldPlayers;
- (NSArray*) getAllPlayers;

- (id) initWithTacticID:(NSInteger) InputID;
- (BOOL) populatePlayer:(Player*) player Position:(PositionChoices)position Side:(SideChoices)side;

- (Player*) getPlayerAtPositionSide:(PositionSide) ps;
- (BOOL) hasPlayerAtPositionSide:(PositionSide) ps;

- (Player*) getPlayerAtPosition:(PositionChoices)position Side:(SideChoices)side;
- (BOOL) movePlayerAtPosition:(PositionChoices)fromposition AtSide:(SideChoices)fromside ToPosition:(PositionChoices)toposition ToSide:(SideChoices)toside;
- (BOOL) updateTacticsInDatabase;

@end
