//
//  GameModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 12/09/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "GameModel.h"
#import "Fixture.h"
#import "DatabaseModel.h"
#import "LineUp.h"
#import "Match.h"

@implementation GameModel
@synthesize myData;
@synthesize GameID;

#pragma mark Initialization Methods

+ (id)myGame
{
    static GameModel *myGame;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myGame = [[self alloc] init];
    });
    return myGame;
}

#pragma mark Accessors

+ (SinglePlayerData*) gameData
{
    return [[self myGame]myData];
}

#pragma mark Data Methods

- (void) newWithGameID:(NSInteger) thisGameID
{
    myData = [[SinglePlayerData alloc]init];
    self.GameID = thisGameID;
    myData.season = 0;
    myData.weekdate = 0;
    myData.week = 0;
    [myData setCurrentLeagueTournament];
    [myData setMyTeam];
}

- (void) loadWithGameID:(NSInteger) thisGameID
{
    GameID = thisGameID;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getGamePath]]) {
        NSData *data = [NSData dataWithContentsOfFile:[self getGamePath]];
        NSDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if ([savedData objectForKey:@"SinglePlayerData"] != nil) {
            self.myData = [savedData objectForKey:@"SinglePlayerData"];
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
    ///Users/junyuanlau/Library/Application Support/iPhone Simulator/7.1/Applications/BB7CF23F-D46F-4F01-A585-322FA24E7E27/Documents

    return  filePath;
}

#pragma mark Game Play Methods

- (void) enterPreWeek
{
    //TODO: - process date
    //TODO: - process cash
    //TODO: - process next match

    myData.weekdate++;
    if (myData.week>50) {
        myData.week = 0;
        [self startSeason];
    }
    myData.week++;
    [myData setNextFixture];
    [myData setNextMatchOpponents];
}

- (void) enterPreTask
{
    
}



- (void) enterTask
{
    
}

- (void) enterPostTask
{
    //TODO: - process training
    //TODO: - process scouting
    //TODO: - process admin
    //TODO: - process task

}

- (void) enterPreGame
{
    myData.currentLineup = [[LineUp alloc]initWithTeam: myData.myTeam];
    myData.currentLineup.currentTactic = myData.currentTactic;
    [myData.myTeam updateConditionPreGame];
    [myData.currentLineup populateMatchDayForm];
    
}

- (void) enterGame
{
    //TODO: - process opponent selection
    [myData setNextMatch];
}

- (void) enterPostGame
{
    //TODO: - process single player fixture
    [myData.nextMatch UpdateMatchFixture];

    //TODO: - process tournament games played
    NSDictionary* tournamentList = [[GlobalVariableModel myGlobalVariableModel]tournamentList];
    [tournamentList enumerateKeysAndObjectsUsingBlock:^(id key, Tournament* t, BOOL *stop) {
        [[t getFixturesForNonSinglePlayerForDate:myData.weekdate] enumerateObjectsUsingBlock:^(Fixture* fx, NSUInteger idx, BOOL *stop) {
            Match* simulateMatch = [[Match alloc]initWithFixture:fx WithSinglePlayerTeam:nil];
            [simulateMatch playFullGame];
            [simulateMatch UpdateMatchFixture];
        }];
        [t setCurrentLeagueTable];
    }];
}

- (void) startSeason
{
    myData.season++;
    NSArray* tournamentList = [[DatabaseModel myDB]getArrayFrom:@"tournaments" withSelectField:@"TOURNAMENTID" WhereString:@"" OrderBy:@"" Limit:@""];
    NSLog(@"Fixture season %i",myData.season);
    [tournamentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Tournament* thisTournament = [[Tournament alloc]initWithTournamentID:[obj integerValue]];
        [thisTournament createFixturesForSeason:myData.season];
    }];
    
    [myData setCurrentLeagueTournament];
}

- (void) endSeason
{
    
}

@end
