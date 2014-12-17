//
//  NewGameTest.m
//  Game2
//
//  Created by Junyuan Lau on 5/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Generator.h"
#import "DatabaseModel.h"
#import "GameModel.h"
#import "LineUp.h"
#import "Scouting.h"
#import "Fixture.h"
#import "Match.h"
#import "Action.h"
#import "Training.h"
#import "GlobalVariableModel.h"

@interface NewGameTest : XCTestCase

@end

@implementation NewGameTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"%@",[[GameModel myDB]databasePath]);

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    NSLog(@"%@",[[GameModel myDB]databasePath]);

}

- (void)testNewGame
{
    [[GameModel myDB]deleteFromTable:@"fixtures" withData:nil];
    [[GameModel myGame]newWithGameID:1];

    [[GameModel myGame]startSeason];

    [[GameModel myGame]saveThisGame];
    
    NSLog(@"Season %i | Week %i",[[GameModel myGame]myData].season, [[GameModel myGame]myData].weekdate);
    NSLog(@"Tournament Name %@",[[GameModel myGame]myData].myTournament.tournamentName);
    NSLog(@"Next Match ID %i",[[GameModel myGame]myData].nextFixture.MATCHID);
}

- (void)testLoadGame
{
    [[GameModel myGame]loadWithGameID:1];
}

- (void)testPrintTable
{
    [[GameModel myGame]loadWithGameID:1];
    NSLog(@"%i",[[[GameModel myGame] myData]myTournament].tournamentID );
    NSLog(@"%@",[[[GameModel myGame] myData]myTournament] );
    
    
    Tournament* temp = [[[GlobalVariableModel myGlobalVariable] tournamentList] objectForKey:@"84"];
    
    NSLog(@"%i",temp.tournamentID);
    NSLog(@"%@",temp);
    
    [[[[GameModel myGame] myData]myTournament]printTable];
}

- (void)testTraining
{
    GameModel* game = [GameModel myGame];
    [game loadWithGameID:1];
    Plan* myPlan = [game.myData.myTraining.Plans objectAtIndex:0];
    NSLog(@"%@", myPlan.thisCoach);
    NSLog(@"%@", myPlan.PlanStats);
    
}

- (void)testNextFixture
{
    GameModel* game = [GameModel myGame];
    [game loadWithGameID:1];
    [game enterPreWeek];
    [game enterPreGame];
    [game.myData.myLineup fillLineup];
    
    [game enterGame];
    
    Match* playGame = game.myData.nextMatch;
    NSLog(@"Team %@-%@",playGame.team1.team.Name,playGame.team2.team.Name);
    
    while (!playGame.isOver) {
        if (playGame.isPaused) {
            if (playGame.hasSP) {
                [game.myData.myLineup subInjured];
                [playGame resumeMatch];
            }
        }
        [playGame nextMinute];
    }
    
    NSLog(@"Score %i-%i",playGame.team1.score,playGame.team2.score);
    NSLog(@"Yellow %i-%i",playGame.team1.yellowCard,playGame.team2.yellowCard);
    NSLog(@"Red %i-%i",playGame.team1.redCard,playGame.team2.redCard);
    [game enterPostGame];
    [game enterPreWeek];
    [game enterPreGame];
    [game enterGame];
    
    playGame = game.myData.nextMatch;
    NSLog(@"Team %@-%@",playGame.team1.team.Name,playGame.team2.team.Name);
    
    while (!playGame.isOver) {
        if (playGame.isPaused) {
            if (playGame.hasSP) {
                [game.myData.myLineup subInjured];
                [playGame resumeMatch];
            }
        }
        [playGame nextMinute];
    }

    NSLog(@"Score %i-%i",playGame.team1.score,playGame.team2.score);
    NSLog(@"Yellow %i-%i",playGame.team1.yellowCard,playGame.team2.yellowCard);
    NSLog(@"Red %i-%i",playGame.team1.redCard,playGame.team2.redCard);
    [game enterPostGame];
    [game enterPreWeek];
    [game enterPreGame];
    
    
    
    NSLog(@"%f",[Action addToRuntime:1 amt:0]);
    NSLog(@"%f",[Action addToRuntime:2 amt:0]);
    NSLog(@"%f",[Action addToRuntime:3 amt:0]);
    NSLog(@"%i",game.myData.myTournament.tournamentID );
    NSLog(@"%@",game.myData.myTournament);
    
    Tournament* temp = [[[GlobalVariableModel myGlobalVariable] tournamentList] objectForKey:@"84"];
    
    NSLog(@"%i",temp.tournamentID);
    NSLog(@"%@",temp);

    [game.myData.myTournament printTable];
}


- (void)testGenerate
{
    
    Generator* newGenerator = [[Generator alloc]init];
    [newGenerator generateNewGameWithTeamName:@"TESTING UNITED"];
    
}

-(void) testDictionaryAccess
{
    NSDate *date = [NSDate date];
    NSInteger r;
    for (int i =0; i<10000; i++){
        r = arc4random()%1000;
        
    }
    
    NSLog(@"%f",[date timeIntervalSinceNow] * -1);
    
    date = [NSDate date];
    for (int i =0; i<10000; i++){
        r = arc4random_uniform(1000);
    }
    NSLog(@"%f",[date timeIntervalSinceNow] * -1);

    /*
    date = [NSDate date];
    for (int i =0; i<10000; i++){
        NSDictionary* ageP = [[GlobalVariableModel myGlobalVariable] ageProfile];
        NSDictionary* pid = [ageP objectForKey:@(0)];
        NSInteger r = arc4random_uniform(20);
        NSDictionary* profile = [pid objectForKey:[NSString stringWithFormat:@"%i",r]];
    }
    NSLog(@"%f",[date timeIntervalSinceNow] * -1);
    
    date = [NSDate date];
    for (int i =0; i<10000; i++){
        NSString* h = @"HELLO";
        NSString* h2 = @"HELLO";
        [h isEqualToString:h];
    }
    NSLog(@"%f",[date timeIntervalSinceNow] * -1);
    */
}

- (void)ttestDatabase
{
    NSArray* players = [[GameModel myDB]getArrayFrom:@"players" withSelectField:@"DISPLAYNAME" whereKeyField:@"PLAYERID" hasKey:@2];
    XCTAssertTrue([players count] == 1,@"get 1 player in players table");
    
}

- (void) testShortlist {
    GameModel* myGame = [GameModel myGame];
    [myGame loadWithGameID:1];
    GlobalVariableModel* globals = [GlobalVariableModel myGlobalVariable];
    [globals playerList];
    
    NSLog(@"%@",[myGame.myData.myScouting getShortList]);
    [myGame.myData.myScouting runAllScouting];
    [myGame.myData.myScouting addPlayersFromResultToShortlist];
    NSLog(@"%@",[myGame.myData.myScouting getShortList]);
    
}

- (void) testScout {

    Scout* newScout = [Scout new];
    newScout.SCOUTPOSITION = ScoutAny;
    newScout.SCOUTTYPE = SquadPlayer;
    newScout.JUDGEMENT = 20;
    newScout.YOUTH = 20;
    newScout.DILIGENCE = 20;
    Player* p =[newScout scoutingResultwithFinalCut:10 RandomCut:20 FirstCut:30 PotentialCut:5 ValueLimit:1000000 Position:ScoutAny AgeLimit:-40];
    NSLog(@"%@",p.DisplayName);
}

- (void) ttestSinglePlayerData
{
    [[GameModel myGame]newWithGameID:1];
    [[GameModel myGame]enterPreWeek];
    
    XCTAssertTrue([[GameModel myGame]nextMatchOpponents].TeamID>0);
}

- (void) ttestFillTeam {
    
    Team* newTeam = [[Team alloc]initWithTeamID:0];
    [newTeam updateFromDatabase];
    LineUp* lineup = [[LineUp alloc]initWithTeam:newTeam];
    lineup.currentTactic = [[Tactic alloc]initWithTacticID:0 WithPlayerDict:nil];
    
    [lineup fillLineup];
    [lineup printFormation];
    
    XCTAssertTrue([lineup validateTactic]);
    
    Team* opp = [[Team alloc]initWithTeamID:1];
    [opp updateFromDatabase];
    LineUp* oppLineup = [[LineUp alloc]initWithTeam:opp];
    oppLineup.currentTactic = [[Tactic alloc]initWithTacticID:2 WithPlayerDict:nil];
    [oppLineup fillLineup];
    [oppLineup printFormation];
    
    
}

@end
