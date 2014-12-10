//
//  SinglePlayerData.m
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "SinglePlayerData.h"
#import "GameModel.h"
#import "Fixture.h"
#import "Tactic.h"
#import "Match.h"
#import "LineUp.h"
#import "Training.h"
#import "Scouting.h"

@implementation SinglePlayerData
@synthesize SaveGameID;
@synthesize myTeam;
@synthesize currentLineup;

@synthesize nextFixture;
@synthesize nextMatch;
@synthesize lastMatch;
@synthesize currentLeagueTournament;
@synthesize nextMatchOpponents;

//Saved Data
@synthesize weekdate;
@synthesize week;
@synthesize season;
@synthesize money;
@synthesize weekStage;
@synthesize weekTask;
@synthesize lineUpPlayers;
@synthesize shortList;

//End Saved data


@synthesize myTraining;
@synthesize myScouting;
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
        self.shortList = [NSMutableArray array];
        self.weekTask = TaskNone;
        self.taskData = [NSMutableDictionary dictionary];
        self.myTraining = [Training new];
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
    self.weekTask = (WeekTask) {[decoder decodeIntegerForKey:@"weekTask"]};
    self.lineUpPlayers = [decoder decodeObjectForKey:@"lineUpPlayers"];
    self.shortList = [decoder decodeObjectForKey:@"shortList"];
    self.taskData = [decoder decodeObjectForKey:@"taskData"];
    self.myTraining = [decoder decodeObjectForKey:@"myTraining"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.weekdate forKey:@"weekdate"];
    [encoder encodeInteger:self.week forKey:@"week"];
    [encoder encodeInteger:self.season forKey:@"season"];
    [encoder encodeInteger:self.money forKey:@"money"];
    [encoder encodeObject:self.weekStage forKey:@"weekStage"];
    [encoder encodeInteger:self.weekTask forKey:@"weekTask"];
    [encoder encodeObject:self.lineUpPlayers forKey:@"lineUpPlayers"];
    [encoder encodeObject:self.shortList forKey:@"shortList"];
    [encoder encodeObject:self.taskData forKey:@"taskData"];

    [encoder encodeObject:self.myTraining.Plans];
    [encoder encodeObject:self.myTraining forKey:@"myTraining"];
}

- (void) setUpData
{
    [self setMyTeam];
    [self setCurrentLeagueTournament];
    [self setNextFixture];
    [self setCurrentLineup];
    //[self setMyTraining];
    [self setMyScouting];
}

- (void) setMyScouting
{
    myScouting = [Scouting new];
}

- (void) setCurrentLeagueTournament
{
    NSInteger tournamentID = myTeam.TournamentID;
    self.currentLeagueTournament = [[[GameModel myGlobalVariableModel] tournamentList] objectForKey:
    [NSString stringWithFormat:@"%i",tournamentID]];
    [currentLeagueTournament setCurrentLeagueTable];
    NSLog(@"Current Tournament - %@",currentLeagueTournament);
    NSLog(@"Current Tournament Table- %@",currentLeagueTournament.currentLeagueTable);

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
