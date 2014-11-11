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

@interface SinglePlayerData : NSObject <NSCoding>
@property NSInteger SaveGameID;
@property Team* myTeam;
@property LineUp* currentLineup;
@property Tactic* currentTactic;

@property Fixture* nextFixture;
@property Match* nextMatch;
@property Fixture* lastMatch;

@property Team* nextMatchOpponents;

@property Tournament* currentLeagueTournament;

@property NSInteger weekdate;
@property NSInteger week;
@property NSInteger season;
@property NSInteger money;

- (void) setNextFixture;
- (void) setCurrentLeagueTournament;
- (void) setCurrentTactic;
- (void) setNextMatchOpponents;
- (void) setMyTeam;
- (void) setNextMatch;
@end
