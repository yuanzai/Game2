//
//  SinglePlayerData.h
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@class Fixture;
@class Tournament;
@class LineUp;
@class Tactic;
@class Match;
@class GameModel;
@class Training;

@interface SinglePlayerData : NSObject <NSCoding>
@property NSInteger SaveGameID;
@property Team* myTeam;
@property LineUp* currentLineup;

@property Fixture* nextFixture;
@property Match* nextMatch;
@property Fixture* lastMatch;

@property Team* nextMatchOpponents;

@property Tournament* currentLeagueTournament;

@property GameModel* myGame;

@property Training* myTraining;

@property NSInteger weekdate;
@property NSInteger week;
@property NSInteger season;
@property NSInteger money;
@property NSString* weekStage;
@property NSString* weekTask;
@property NSMutableDictionary* lineUpPlayers;


- (void) setUpData;

- (void) setNextFixture;
- (void) setCurrentLeagueTournament;
- (void) setNextMatchOpponents;
- (void) setMyTeam;
- (void) setNextMatch;
@end
