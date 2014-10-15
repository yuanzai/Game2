//
//  Fixture.h
//  MatchEngine
//
//  Created by Junyuan Lau on 29/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@interface Tournament : NSObject
@property NSString* tournamentName;
@property NSInteger tournamentID;
@property NSString*	tournamentType;
@property NSInteger teamCount;
@property NSInteger promoteToTournament;
@property NSInteger relegateToTournament;
@property NSInteger promoteCount;
@property NSInteger relegateCount;

- (id) initWithTournamentID:(NSInteger) TournamentID;

- (BOOL) createFixturesForSeason:(NSInteger)season;
- (NSArray*) getAllFixturesForSeason:(NSInteger)season;
- (NSArray*) getFixturesForTeam:(Team*) team ForSeason:(NSInteger)season;
- (NSArray*) getLeagueTableForSeason:(NSInteger)season;
- (void) getPromotionAndRelegationForSeason:(NSInteger) season;

@end

@interface Fixture : NSObject
@property BOOL hasPenalties;
@property BOOL hasExtraTime;
@property Tournament* thisTournement;
@property NSInteger Week;
@property NSInteger team1ID;
@property NSInteger team2ID;
@property Team* team1;
@property Team* team2;

-(void) updateFixtureInDatabase;

@end
