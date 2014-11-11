//
//  SinglePlayerData.m
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "SinglePlayerData.h"
#import "DatabaseModel.h"
#import "Team.h"
#import "Fixture.h"
#import "Tactic.h"
#import "Match.h"
#import "LineUp.h"

@implementation SinglePlayerData
@synthesize SaveGameID;
@synthesize myTeam;
@synthesize currentLineup;

@synthesize nextFixture;
@synthesize nextMatch;
@synthesize lastMatch;
@synthesize currentLeagueTournament;
@synthesize nextMatchOpponents;

@synthesize weekdate;
@synthesize week;
@synthesize season;
@synthesize money;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.weekdate = [decoder decodeIntegerForKey:@"weekdate"];
    self.week = [decoder decodeIntegerForKey:@"week"];
    self.season = [decoder decodeIntegerForKey:@"season"];
    self.money = [decoder decodeIntegerForKey:@"money"];
    [self setCurrentLeagueTournament];
    [self setNextFixture];
    [self setCurrentTactic];
    [self setMyTeam];
    [self setCurrentLineup];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.weekdate forKey:@"weekdate"];
    [encoder encodeInteger:self.week forKey:@"week"];
    [encoder encodeInteger:self.season forKey:@"season"];
    [encoder encodeInteger:self.money forKey:@"money"];
}

- (void) setCurrentLeagueTournament
{
    self.currentLeagueTournament = [[Tournament alloc]initWithTournamentID: [[[[DatabaseModel myDB]getArrayFrom:@"teams" withSelectField:@"TOURNAMENTID" whereKeyField:@"TEAMID" hasKey:@0]objectAtIndex:0]integerValue]];

}

- (void) setNextFixture
{
    self.nextFixture = [self.currentLeagueTournament getMatchForTeamID:0 Date:weekdate];

}

- (void) setNextMatchOpponents
{
    NSInteger OppID = nextFixture.HOMETEAM == 0 ? nextFixture.AWAYTEAM : nextFixture.HOMETEAM;
    self.nextMatchOpponents = [[Team alloc]initWithTeamID:OppID];
}
        
- (void) setCurrentTactic
{
    self.currentTactic = [[Tactic alloc]initWithTacticID:0];
}

- (void) setMyTeam
{
    myTeam = [[Team alloc]initWithTeamID:0];
}

- (void) setNextMatch
{
    nextMatch = [[Match alloc]initWithFixture:nextFixture WithSinglePlayerTeam:currentLineup];
}

- (void) setCurrentLineup
{
    currentLineup = [[LineUp alloc]initWithTeamID:0];
    currentLineup.currentTactic = [[Tactic alloc]initWithTacticID:0];
}
/*
- (void) setLastMatch;
{
    if (weekdate > 1) {
        self.nextMatch = [self.currentLeagueTournament getMatchForTeamID:0 Date:weekdate-1];
    }
    
}
*/
@end
