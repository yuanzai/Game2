//
//  SinglePlayerData.h
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
@class Team;
@class Fixture;
@class Tournament;
@class LineUp;
@class Tactic;
@class Match;
@class GameModel;
@class Training;
@class Scouting;

@interface SinglePlayerData : NSObject <NSCoding>
@property GameModel* myGame;
@property NSInteger SaveGameID;

@property Team* myTeam;
@property LineUp* currentLineup;
@property Tournament* currentLeagueTournament;
@property Training* myTraining;
@property Scouting* myScouting;


@property Fixture* nextFixture;
@property Match* nextMatch;
@property Fixture* lastMatch;
@property Team* nextMatchOpponents;



@property NSInteger weekdate;
@property NSInteger week;
@property NSInteger season;
@property NSInteger money;
@property NSString* weekStage;
@property WeekTask weekTask;
@property NSMutableDictionary* taskData;

@property NSMutableDictionary* lineUpPlayers;
@property NSMutableArray* shortList;


- (void) setUpData;

- (void) setNextFixture;
- (void) setCurrentLeagueTournament;
- (void) setNextMatchOpponents;
- (void) setMyTeam;
- (void) setNextMatch;
@end
