//
//  GameModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 12/09/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "GameModel.h"
#import "Fixture.h"
#import "LineUp.h"
#import "Match.h"
#import "Generator.h"
#import "Task.h"
#import "Training.h"
#import "Scouting.h"

@implementation GameModel
@synthesize myData;
@synthesize GameID;
@synthesize myDB;
//@synthesize myGlobalVariableModel;
@synthesize myStoryboard;
@synthesize source;

#pragma mark Initialization Methods

+ (id)myGame
{
    static GameModel *myGame;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myGame = [[self alloc] init];
        myGame.myDB = [DatabaseModel new];
        myGame.myStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        myGame.source = [NSMutableDictionary dictionary];
    });
    return myGame;
}

#pragma mark Accessors

+ (SinglePlayerData*) gameData
{
    return [[self myGame]myData];
}

+ (DatabaseModel*) myDB
{
    return [[self myGame]myDB];
}

#pragma mark Data Methods

- (void) newWithGameID:(NSInteger) thisGameID
{
    Generator* newGenerator = [[Generator alloc]init];
    [newGenerator generateNewGameWithTeamName:@"TESTING UNITED"];
    
    [[GameModel myDB]deleteFromTable:@"fixtures" withData:nil];
    [[GameModel myDB]deleteFromTable:@"trainingExp" withData:nil];

    myData = [[SinglePlayerData alloc]init];
    GameID = thisGameID;

    myData.SaveGameID = thisGameID;
    self.myData.myGame = self;
    
    //Setup Training New Coach
    
    [myData setUpData];
    
    Plan* thisPlan = [myData.myTraining.Plans objectAtIndex:0];
    thisPlan.isActive = YES;
    thisPlan.thisCoach = [newGenerator generateNewCoachWithAbility:45];
    thisPlan.PlayerList = [NSMutableSet setWithArray:myData.myTeam.PlayerList];
    for (Player* p in thisPlan.PlayerList) {
        [thisPlan.PlayerIDList addObject:@(p.PlayerID)];
    }
    
    //Setup Scouting New Scout
    [myData.myScouting.scoutArray setObject:[newGenerator generateNewScoutWithAbility:32] atIndexedSubscript:0];
    Scout* newScout =[myData.myScouting.scoutArray objectAtIndex:0];
    newScout.ISACTIVE = YES;
    
    [[GameModel myGame]enterPreWeek];
    [[GameModel myGame]saveThisGame];
}

- (void) loadWithGameID:(NSInteger) thisGameID
{
    NSLog(@"Load Game");
    GameID = thisGameID;

    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getGamePath]]) {
        NSData *data = [NSData dataWithContentsOfFile:[self getGamePath]];
        NSDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if ([savedData objectForKey:@"SinglePlayerData"] != nil) {
            self.myData = [savedData objectForKey:@"SinglePlayerData"];
            self.myData.SaveGameID = thisGameID;
            self.myData.myGame = self;
            [myData setUpData];

            if ([myData.weekStage isEqualToString:@""] || myData.weekStage == nil)
                myData.weekStage = @"enterPreWeek";
            if ([myData.weekStage isEqualToString:@"enterPlan"])
                myData.weekStage = @"enterTraining";
        }
    }
}

- (void) saveThisGame
{
    NSDictionary* savedData = [[NSDictionary alloc]initWithObjectsAndKeys:self.myData,@"SinglePlayerData", nil];
    [NSKeyedArchiver archiveRootObject:savedData toFile:[self getGamePath]];

}

- (NSString*) getGamePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"SaveGame%i",GameID]];
    return  filePath;
}

#pragma mark View Controller Methods

#pragma mark Game Play Methods

- (void) enterPreWeek
{
    //TODO: - process cash
    NSLog(@"enterPreWeek");
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    [self saveThisGame];
    
    myData.weekdate++;
    if (myData.week>50) {
        myData.week = 0;
    }
    
    if (myData.week == 0) {
        [self startSeason];
    }
    myData.week++;
    [myData setNextFixture];
    [myData setLastFixture];
    [myData setNextMatchOpponents];
}

- (void) enterPreTask
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    myData.weekTask = TaskNone;
    [self saveThisGame];
}

- (void) setTask:(WeekTask) task
{
    myData.weekTask = task;
}

- (void) enterTask
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    //myData.weekTask = TaskNone;
    [self saveThisGame];
}

- (void) enterPostTask
{
    // scout task
    
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    Task* newTask = [[Task alloc]init];
    [newTask runTask];
    [self saveThisGame];
}

- (void) enterPreGame
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    [myData.myTeam updateConditionPreGame];
    [myData.myLineup populateMatchDayForm];
    [self saveThisGame];
}

- (void) enterGame
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];

    [myData setNextMatch];
    //[self saveThisGame];
}

- (void) enterPostGame
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    [source setObject:@([myData.myTournament getTeamPositionInLeague:0]) forKey:@"previousLeaguePosition"];

    NSLog(@"Updating Match Fixture");
    [myData.nextMatch updateMatchFixture];

    NSLog(@"Updating All Match Fixtures");
    NSDictionary* tournamentList = [[GlobalVariableModel myGlobalVariable] tournamentList];
    
    [tournamentList enumerateKeysAndObjectsUsingBlock:^(id key, Tournament* t, BOOL *stop) {
        NSArray* thisT = [t getFixturesForNonSinglePlayerForDate:myData.weekdate];
        for (Fixture* fx in thisT) {
            if (fx.PLAYED ==0) {
                //Match* simulateMatch = [[Match alloc]initWithFixture:fx WithSinglePlayerTeam:nil];
                //NSLog(@"%i %i %@ v %@",t.tournamentID,fx.MATCHID,simulateMatch.team1.team.Name, simulateMatch.team2.team.Name);
                //[simulateMatch playFullGame];
                //[simulateMatch updateMatchFixture];
            }
        }
        [t setCurrentLeagueTable];
    }];
    [myData.myTraining runAllPlans];
    [myData.myScouting runAllScouting];
    [myData.myScouting removeExcessPlayersFromShortlist];
    [myData.myScouting addPlayersFromResultToShortlist];
    [myData.myLineup.currentTactic validateTactic];
    
    if (!source)
        source = [NSMutableDictionary dictionary];
    
    [source setObject:@([myData.myTraining getUpStats]) forKey:@"trainingUpStats"];
    [source setObject:@([myData.myTraining getDownStats]) forKey:@"trainingDownStats"];
    [source setObject:@([myData.myTraining getUpExp]) forKey:@"trainingUpExp"];
    [source setObject:@([myData.myTraining getDownExp]) forKey:@"trainingDownExp"];
    
    [source setObject:@([[myData.myScouting getAllScoutsResults] count]) forKey:@"scoutingCount"];
    [source setObject:@([myData.myTournament getTeamPositionInLeague:0]) forKey:@"currentLeaguePosition"];
    [source setObject:[myData.myTournament getScoresForNonSinglePlayerForDate:myData.weekdate] forKey:@"scores"];
    
    NSLog(@"%@",myData.myScouting.shortListID);
    [self saveThisGame];
}

//Parellel views

- (void) enterTraining
{
}

- (void) enterPlan
{
}


- (void) enterTactic
{
    [source setObject:@"enterTactic" forKey:@"source"];
}

- (void) exitTactic
{
    [self saveThisGame];
}


- (void) enterPlayers
{

}

- (void) enterPlayerInfo
{

}

- (void) exitPlayers
{
}


- (void) startSeason
{
    myData.season++;
    NSDictionary* tournamentList = [[GlobalVariableModel myGlobalVariable] tournamentList];
    NSLog(@"Fixture season %i",myData.season);
    [tournamentList enumerateKeysAndObjectsUsingBlock:^(id key, Tournament* t, BOOL *stop) {
        [t createFixturesForSeason:myData.season];
    }];
     
    [myData setMyTournament];
}

- (void) endSeason
{

}

//TODO: Finances

@end
