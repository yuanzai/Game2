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

@implementation GameModel
@synthesize myData;
@synthesize GameID;

#pragma mark Initialization Methods

+ (id)myGame {
    static GameModel *myGame = nil;
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

- (void) newWithGameID:(NSInteger) GameID
{
    myData.season = 0;
    myData.weekdate = 0;
    myData.week = 0;
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
    NSDictionary* savedData = [[NSDictionary alloc]initWithObjectsAndKeys:myData,@"SinglePlayerData", nil];
    [NSKeyedArchiver archiveRootObject:savedData toFile:[self getGamePath]];
}

- (NSString*) getGamePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"SaveGame%i",GameID]];
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
    [myData setNextMatch];
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
    myData.currentLineup = (LineUp*) myData.myTeam;
    myData.currentLineup.currentTactic = myData.currentTactic;
    [myData.currentLineup populateMatchDayForm];
    
    myData.nextMatchOpponents = (LineUp*) myData.nextMatchOpponents;
}

- (void) enterGame
{
    //TODO: - process opponent selection

}

- (void) enterPostGame
{
    //TODO: - process tournament games played
    //TODO: - process single player fixture

}

- (void) startSeason
{
    myData.season++;
    NSArray* tournamentList = [[[DatabaseModel alloc]init]getArrayFrom:@"tournaments" withSelectField:@"TOURNAMENTID" WhereString:@"" OrderBy:@"" Limit:@""];
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
