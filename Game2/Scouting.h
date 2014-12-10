//
//  Scouting.h
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//


/*
Player Actionables
 1) task - scouting
  - scout team
  - scout youth
  - scout region
  - scout everywhere
 
Factors
 1) real life time needed to scout?
 2) turn based scouting?
 3) immediate scouting results?
 4) fine tune scouting?
 5) scout perk/ability
 6)
 */

typedef enum {
    SquadPlayer,
    StarPlayer,
    Youth
} ScoutTypes;

typedef enum {
    ScoutAny,
    ScoutGoalkeeper,
    ScoutDef,
    ScoutMid,
    ScoutAtt
} ScoutPosition;

#import <Foundation/Foundation.h>
@class Scout;
@interface Scouting : NSObject
@property Scout* scout0;
@property Scout* scout1;
@property Scout* scout2;
@property Scout* scout3;
@property NSMutableArray* scoutArray;


- (void) updateAllScoutsToDatabase;

- (void) runAllScouting;

@end

@interface Scout : NSObject
@property NSInteger SCOUTID;
@property NSString* NAME;
@property NSInteger JUDGEMENT; // judging ability + potential
@property NSInteger YOUTH; // judging potential in < 23yr olds
@property NSInteger VALUE; // abilty to price ratio
@property NSInteger KNOWLEDGE; // useful perks spotting
@property NSInteger DILIGENCE; // probabilty of more names
@property BOOL ISACTIVE;
@property ScoutTypes SCOUTTYPE;
@property ScoutPosition SCOUTPOSITION;
@property NSMutableArray* scoutResults;
@property NSArray* valueArray;

- (id) initWithScoutID: (NSInteger) thisScoutID;
- (void) updateScoutToDatabase;

- (BOOL) isScoutingSuccess;
- (NSArray*) getScoutingPlayerArray;

- (NSString*) getStringForScoutType:(ScoutTypes)type;
- (NSString*) getStringForScoutPosition:(ScoutPosition) pos;

@end

