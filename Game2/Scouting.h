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
@class Player;
@class Scout;
@class GameModel;
@interface Scouting : NSObject<NSCoding>
@property NSMutableArray* scoutArray;
@property NSMutableArray* shortListID;
@property NSInteger shortListLimit;
@property GameModel* myGame;
@property NSInteger lastRun;

- (NSArray*) getAllScoutsResults;
- (void) runAllScouting;
- (void) removeExcessPlayersFromShortlist;
- (void) addPlayersFromResultToShortlist;
- (void) addPlayerToShortList:(Player*)player;
- (void) removeFromShortList:(Player*)player;
- (NSArray*) getShortList;



@end

@interface Scout : NSObject <NSCoding>
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
@property GameModel* myGame;

- (BOOL) isScoutingSuccess;
- (NSArray*) getScoutingPlayerArray;
- (NSString*) getStringForScoutType:(ScoutTypes)type;
- (NSString*) getStringForScoutPosition:(ScoutPosition) pos;

- (Player*) scoutingResultwithFinalCut:(NSInteger) finalCut
                             RandomCut:(NSInteger) randomCut
                              FirstCut:(NSInteger) firstCut
                          PotentialCut:(NSInteger) potentialCut
                            ValueLimit:(double) valueLimit
                              Position:(ScoutPosition) pos
                              AgeLimit:(NSInteger) ageLimit;


@end

