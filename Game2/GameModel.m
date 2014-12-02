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
#import "Generator.h"

#import "ViewController.h"
#import "TacticViewController.h"
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
/* 
    if (![[self myGame]myDB]){
        GameModel* myGame = [self myGame];
        myGame.myDB = [DatabaseModel new];
    }*/
    return [[self myGame]myDB];
}


+ (GlobalVariableModel*) myGlobalVariableModel
{
    /*
    if (![[self myGame]myGlobalVariableModel]){
        GameModel* myGame = [self myGame];
        myGame.myGlobalVariableModel = [GlobalVariableModel new];
    }*/
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
    [[GameModel myGame]startSeason];
    [[GameModel myGame]saveThisGame];
    [self goToView];


}

- (void) loadWithGameID:(NSInteger) thisGameID
{
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
    ///Users/junyuanlau/Library/Application Support/iPhone Simulator/7.1/Applications/BB7CF23F-D46F-4F01-A585-322FA24E7E27/Documents

    return  filePath;
}

#pragma mark View Controller Methods
- (void) goToView
{    
    ViewController *vc = (ViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier:myData.weekStage];
    [currentViewController presentViewController:vc animated:YES completion:nil];
    /*
    [vc getButtons];
    
    for (id subview in vc.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]])
            [(UIButton*) subview addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    */
    currentViewController = vc;
}


#pragma mark Game Play Methods

- (void) enterPreWeek
{
    //TODO: - process date
    //TODO: - process cash
    //TODO: - process next match
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    [self saveThisGame];
    
    myData.weekdate++;
    if (myData.week>50) {
        myData.week = 0;
        [self startSeason];
    }
    myData.week++;
    [myData setNextFixture];
    [myData setNextMatchOpponents];
    
    [self goToView];
}

- (void) enterPreTask
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    myData.weekTask = nil;
    [self goToView];
}

- (void) setTask:(NSString*) task
{
    myData.weekTask = task;
}

- (void) enterTask
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    myData.weekTask = nil;
    [self goToView];
}

- (void) enterPostTask
{
    //TODO: - process training
    //TODO: - process scouting
    //TODO: - process admin
    //TODO: - process task
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];

    [self goToView];
}

- (void) enterPreGame
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];

    myData.currentLineup = [[LineUp alloc]initWithTeam: myData.myTeam];
    myData.currentLineup.currentTactic = myData.currentTactic;
    [myData.myTeam updateConditionPreGame];
    [myData.currentLineup populateMatchDayForm];
    [self goToView];

}

- (void) enterGame
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];

    //TODO: - process opponent selection
    [myData setNextMatch];
    [self goToView];

}

- (void) enterPostGame
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];

    //TODO: - process single player fixture
    [myData.nextMatch updateMatchFixture];

    //TODO: - process tournament games played
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
    [self goToView];
}

- (void) enterTraining
{
    myData.weekStage = [NSString stringWithFormat:@"%@",NSStringFromSelector(_cmd)];
    [self goToView];
}

- (void) enterPlanWith:(NSDictionary*) source
{
    PlanViewController *vc = [currentViewController.storyboard instantiateViewControllerWithIdentifier:@"enterPlan"];

    vc.source = source;
    [currentViewController presentViewController:vc animated:YES completion:nil];
    currentViewController = vc;

}


- (void) enterTacticFrom:(NSDictionary*) source
{
    myData.weekStage = @"enterTactic";
    TacticViewController *vc = [currentViewController.storyboard instantiateViewControllerWithIdentifier:myData.weekStage];
    vc.source = source;
    [currentViewController presentViewController:vc animated:YES completion:nil];
    currentViewController = vc;
}

- (void) exitTacticTo:(NSDictionary*) source
{
    SEL s = NSSelectorFromString([NSString stringWithFormat:@"%@", [source objectForKey:@"source"]]);
    [self performSelector:s];
}


- (void) enterPlayersFrom:(NSDictionary*) source
{
    PlayersViewController *vc = [currentViewController.storyboard instantiateViewControllerWithIdentifier:@"enterPlayers"];
    vc.source = source;
    [currentViewController presentViewController:vc animated:YES completion:nil];
    currentViewController = vc;
}

- (void) exitPlayersTo:(NSDictionary*) source
{
    if ([[source objectForKey:@"source"] isEqualToString:@"enterTactic"]) {
        [self enterTacticFrom:[source objectForKey:@"supersource"]];
    } else if ([[source objectForKey:@"source"] isEqualToString:@"enterPlanPlayers"]) {
        NSMutableDictionary* newSource = [NSMutableDictionary dictionaryWithDictionary:source];
        [newSource setObject:[source objectForKey:@"supersource"] forKey:@"source"];
        [self enterPlanWith:newSource];
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

@end
