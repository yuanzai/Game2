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

#import "ViewController.h"
#import "PlayersViewController.h"
#import "PlayerInfoViewController.h"
#import "PlanViewController.h"

@implementation GameModel
@synthesize myData;
@synthesize GameID;
@synthesize myDB;
@synthesize myGlobalVariableModel;
@synthesize myStoryboard;
@synthesize currentViewController;
@synthesize source;

#pragma mark Initialization Methods

+ (id)myGame
{
    static GameModel *myGame;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myGame = [[self alloc] init];
        myGame.myDB = [DatabaseModel new];
        myGame.myGlobalVariableModel = [GlobalVariableModel new];
        myGame.myStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
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


+ (GlobalVariableModel*) myGlobalVariableModel
{
    return [[self myGame]myGlobalVariableModel];
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
    [myData setUpData];
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
            [self goToView];
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
- (void) goToView
{
    ViewController *vc = (ViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier:myData.weekStage];
    [currentViewController presentViewController:vc animated:YES completion:nil];
    currentViewController = vc;
}


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
    [myData setNextMatchOpponents];
    [myData.currentLeagueTournament setCurrentLeagueTable];
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
    myData.weekTask = TaskNone;
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
    [myData.currentLineup populateMatchDayForm];
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

    NSLog(@"Updating Match Fixture");
    [myData.nextMatch updateMatchFixture];

    NSLog(@"Updating All Match Fixtures");
    NSDictionary* tournamentList = [myGlobalVariableModel tournamentList];
    
    [tournamentList enumerateKeysAndObjectsUsingBlock:^(id key, Tournament* t, BOOL *stop) {
        NSArray* thisT = [t getFixturesForNonSinglePlayerForDate:myData.weekdate];
        for (Fixture* fx in thisT) {
            Match* simulateMatch = [[Match alloc]initWithFixture:fx WithSinglePlayerTeam:nil];
            NSLog(@"%i %i %@ v %@",t.tournamentID,fx.MATCHID,simulateMatch.team1.team.Name, simulateMatch.team2.team.Name);
            [simulateMatch playFullGame];
            [simulateMatch updateMatchFixture];
        }
        [t setCurrentLeagueTable];
    }];
    
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
    ViewController *vc = [currentViewController.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)]];
    [currentViewController presentViewController:vc animated:YES completion:nil];
    currentViewController = vc;
}

- (void) exitTactic
{
    [self saveThisGame];
}


- (void) enterPlayers
{
    NSLog(@"enterPlayers");
    NSLog(@"%@",currentViewController);
    PlayersViewController *vc = [currentViewController.storyboard instantiateViewControllerWithIdentifier:@"enterPlayers"];
    [currentViewController presentViewController:vc animated:YES completion:nil];
    currentViewController = vc;
    
}

- (void) enterPlayerInfo
{
    PlayerInfoViewController *vc = [currentViewController.storyboard instantiateViewControllerWithIdentifier:@"enterInfo"];;
    [currentViewController presentViewController:vc animated:YES completion:nil];
}

- (void) exitPlayers
{
    NSString* sourceString = [source objectForKey:@"source"];
    if ([sourceString isEqualToString:@"enterTactic"]) {
        [self enterTactic];
    } else if ([sourceString isEqualToString:@"enterPreGame"]) {
        [self goToView];
    } else if ([sourceString isEqualToString:@"enterPlanPlayers"]) {
        [self enterPlan];
    }
}


- (void) startSeason
{
    myData.season++;
    NSDictionary* tournamentList = [myGlobalVariableModel tournamentList];
    NSLog(@"Fixture season %i",myData.season);
    [tournamentList enumerateKeysAndObjectsUsingBlock:^(id key, Tournament* t, BOOL *stop) {
        [t createFixturesForSeason:myData.season];
    }];
     
    [myData setCurrentLeagueTournament];
}

- (void) endSeason
{

}


//TODO: Finances

@end
