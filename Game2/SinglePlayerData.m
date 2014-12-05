//
//  SinglePlayerData.m
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "SinglePlayerData.h"
#import "GameModel.h"
#import "DatabaseModel.h"
#import "Team.h"
#import "Fixture.h"
#import "Tactic.h"
#import "Match.h"
#import "LineUp.h"
#import "Training.h"

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
@synthesize weekStage;
@synthesize weekTask;
@synthesize lineUpPlayers;

@synthesize myTraining;

@synthesize myGame;

- (id) init
{
    self = [super init];
    if (self) {
        self.season = 0;
        self.weekdate = 0;
        self.week = 0;
        self.weekStage = @"enterPreWeek";
        self.lineUpPlayers = [NSMutableDictionary dictionary];
    }; return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.weekdate = [decoder decodeIntegerForKey:@"weekdate"];
    self.week = [decoder decodeIntegerForKey:@"week"];
    self.season = [decoder decodeIntegerForKey:@"season"];
    self.money = [decoder decodeIntegerForKey:@"money"];
    self.weekStage = [decoder decodeObjectForKey:@"weekStage"];
    self.weekTask = [decoder decodeObjectForKey:@"weekTask"];
    self.lineUpPlayers = [decoder decodeObjectForKey:@"lineUpPlayers"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.weekdate forKey:@"weekdate"];
    [encoder encodeInteger:self.week forKey:@"week"];
    [encoder encodeInteger:self.season forKey:@"season"];
    [encoder encodeInteger:self.money forKey:@"money"];
    [encoder encodeObject:self.weekStage forKey:@"weekStage"];
    [encoder encodeObject:self.weekTask forKey:@"weekTask"];
    [encoder encodeObject:self.lineUpPlayers forKey:@"lineUpPlayers"];
}

- (void) setUpData
{
    [self setMyTeam];
    [self setCurrentLeagueTournament];
    [self setNextFixture];
    [self setCurrentLineup];
    [self setMyTraining];
}

- (void) setCurrentLeagueTournament
{
    NSInteger tournamentID = myTeam.TournamentID;
    self.currentLeagueTournament = [[[GameModel myGlobalVariableModel] tournamentList] objectForKey:
    [NSString stringWithFormat:@"%i",tournamentID]];
    NSLog(@"Current Tournament - %@",currentLeagueTournament);

}

- (void) setNextFixture
{
    self.nextFixture = [self.currentLeagueTournament getMatchForTeamID:0 Date:weekdate];
    NSLog(@"Next Fixture- %@",nextFixture);

}

- (void) setNextMatchOpponents
{
    NSInteger OppID = nextFixture.HOMETEAM == 0 ? nextFixture.AWAYTEAM : nextFixture.HOMETEAM;
    self.nextMatchOpponents = [[Team alloc]initWithTeamID:OppID];
}
        
- (void) setMyTeam
{
    myTeam = [[[GameModel myGlobalVariableModel] teamList]objectForKey:@"0"];
}

- (void) setNextMatch
{
    nextMatch = [[Match alloc]initWithFixture:nextFixture WithSinglePlayerTeam:currentLineup];
}

- (void) setCurrentLineup
{
    currentLineup = [[LineUp alloc]initWithTeamID:0];
    currentLineup.currentTactic = [[Tactic alloc]initWithTacticID:0 WithPlayerDict:lineUpPlayers];
}

- (void) setMyTraining
{
    myTraining = [[Training alloc]init];
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
