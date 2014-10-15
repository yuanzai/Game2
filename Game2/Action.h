//
//  Action.h
//  MatchEngine
//
//  Created by Junyuan Lau on 22/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LineUp.h"

@class LineUp;
@class MatchPlayer;
typedef enum {
    GK,
    Own,
    Opp,
    Area,
    ZoneCount
} Zone;

typedef enum {
    GKFlank,
    LeftFlank,
    CentreFlank,
    RightFlank,
    FlankCount
} Flank;

struct ZoneFlank {
    Zone zone;
    Flank flank;
};

typedef struct ZoneFlank ZoneFlank;


typedef enum {
    Success,
    AttackFoul,
    DefenseFoul,
    AttackYellow,
    AttackRed,
    DefenseYellow,
    DefenseRed,
    Offside,
    Goal,
    Corner,
    Save,
    Fail,
    OffTarget
} ActionResult;

@interface Action : NSObject
{
    NSString* AttackType;
    NSString* DefenseType;
    PositionSide FromPositionSide;
    PositionSide ToPositionSide;
    ZoneFlank FromZoneFlank;
    ZoneFlank ToZoneFlank;
    
    PositionSide OppPositionSide;
    MatchPlayer* FromPlayer;
    MatchPlayer* ToPlayer;
    MatchPlayer* OppPlayer;
    MatchPlayer* OppKeeper;
    
    LineUp* thisTeam;
    LineUp* oppTeam;
    
    NSString* NextAttack;
    ActionResult result;
    MatchPlayer* injuredPlayer;
    NSString* Commentary;
    double attQuotient;
    double defQuotient;
    
    Action* previousAction;
    int actionCount;
}
@property NSString* AttackType;
@property NSString* DefenseType;
@property PositionSide FromPositionSide;
@property PositionSide ToPositionSide;
@property ZoneFlank FromZoneFlank;
@property ZoneFlank ToZoneFlank;
@property PositionSide OppPositionSide;
@property MatchPlayer* FromPlayer;
@property MatchPlayer* ToPlayer;
@property MatchPlayer* OppPlayer;
@property MatchPlayer* OppKeeper;

@property LineUp* thisTeam;
@property LineUp* oppTeam;

@property NSString* NextAttack;
@property ActionResult result;
@property MatchPlayer* injuredPlayer;
@property NSString* Commentary;
@property double attQuotient;
@property double defQuotient;

@property Action* previousAction;
@property int actionCount;

- (void) setActionProperties;
@end
