//
//  Action.h
//  MatchEngine
//
//  Created by Junyuan Lau on 22/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
#import "GlobalVariableModel.h"
#import "DatabaseModel.h"
#import "LineUp.h"

@class LineUp;
@class Player;


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
    Player* FromPlayer;
    Player* ToPlayer;
    Player* OppPlayer;
    Player* OppKeeper;
    
    LineUp* thisTeam;
    LineUp* oppTeam;
    
    NSString* NextAttack;
    ActionResult result;
    Player* injuredPlayer;
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
@property Player* FromPlayer;
@property Player* ToPlayer;
@property Player* OppPlayer;
@property Player* OppKeeper;

@property LineUp* thisTeam;
@property LineUp* oppTeam;

@property NSString* NextAttack;
@property ActionResult result;
@property Player* injuredPlayer;
@property NSString* Commentary;
@property double attQuotient;
@property double defQuotient;

@property Action* previousAction;
@property int actionCount;

- (void) setActionProperties;
+ (double) addToRuntime:(int)no amt:(double) amt;

@end
