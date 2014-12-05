//
//  Fixture.h
//  MatchEngine
//
//  Created by Junyuan Lau on 29/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@class  Fixture;
@interface Tournament : NSObject
@property NSString* tournamentName;
@property NSInteger tournamentID;
@property NSString*	tournamentType;
@property NSInteger teamCount;
@property NSInteger promoteToTournament;
@property NSInteger relegateToTournament;
@property NSInteger promoteCount;
@property NSInteger relegateCount;
@property NSInteger playerCount;
@property NSArray* currentLeagueTable;


- (id) initWithTournamentID:(NSInteger) TournamentID;

- (BOOL) createFixturesForSeason:(NSInteger)season;
- (NSArray*) getAllFixturesForSeason:(NSInteger)season;
- (NSArray*) getFixturesForTeam:(Team*) team ForSeason:(NSInteger)season Remaining:(BOOL) remainingOnly;
- (NSArray*) getLeagueTableForSeason:(NSInteger)season;
- (void) getPromotionAndRelegationForSeason:(NSInteger) season;

- (NSArray*) getFixturesForNonSinglePlayerForDate:(NSInteger)date;


- (Fixture*) getMatchForTeamID:(NSInteger) teamID Date:(NSInteger) date;

- (void) setCurrentLeagueTable;
- (void) printTable;

@end


@interface Fixture : NSObject
@property NSInteger MATCHID;
@property NSInteger TOURNAMENTID;
@property NSInteger SEASON;
@property NSInteger DATE;
@property NSInteger ROUND;
@property NSInteger HOMETEAM;
@property NSInteger AWAYTEAM;
@property NSInteger HOMESCORE;
@property NSInteger AWAYSCORE;
@property NSInteger HOMEYELLOW;
@property NSInteger HOMERED;
@property NSInteger AWAYYELLOW;
@property NSInteger AWAYRED;
@property NSInteger HASET;
@property NSInteger PLAYEDET;
@property NSInteger HASPENALTIES;
@property NSInteger PLAYEDPENALTIES;
@property NSInteger HOMEPENALTIES;
@property NSInteger AWAYPENALTIES;
@property NSInteger HOMELOGJSON;
@property NSInteger AWAYLOGJSON;
@property NSInteger PLAYED;

@property Team* homeTeam;
@property Team* awayTeam;

-(void) updateFixtureInDatabase;
- (id) initWithMatchID:(NSInteger) thisMatchID;
@end
