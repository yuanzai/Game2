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
@interface NewGameTest : XCTestCase

@end

@implementation NewGameTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"%@",[[DatabaseModel myDB]databasePath]);

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    NSLog(@"%@",[[DatabaseModel myDB]databasePath]);

}

- (void)testNewGame
{
    [[DatabaseModel myDB]deleteFromTable:@"fixtures" withData:nil];
    [[GameModel myGame]newWithGameID:1];

    [[GameModel myGame]startSeason];

    [[GameModel myGame]enterPreWeek];
    [[GameModel myGame]saveThisGame];
    NSLog(@"Season %i",[[GameModel myGame]myData].season);
    NSLog(@"Week %i",[[GameModel myGame]myData].weekdate);
    
    NSLog(@"Tournament Name %@",[[GameModel myGame]myData].currentLeagueTournament.tournamentName);

    NSLog(@"Next Match ID %i",[[GameModel myGame]myData].nextFixture.MATCHID);
}

- (void)testLoadGame
{
    [[GameModel myGame]loadWithGameID:1];
    
    NSLog(@"Season %i",[[GameModel myGame]myData].season);
    NSLog(@"Week %i",[[GameModel myGame]myData].weekdate);
    
    NSLog(@"Tournament Name %@",[[GameModel myGame]myData].currentLeagueTournament.tournamentName);
    NSLog(@"Next Match ID %i",[[GameModel myGame]myData].nextFixture.MATCHID);
}

- (void)testNextFixture
{
    [[GameModel myGame]loadWithGameID:1];
    [[GameModel myGame]enterPreGame];

    [[[GameModel myGame]myData].currentLineup removeAllPlayers];
    [[[GameModel myGame]myData].currentLineup fillOutfieldPlayers];
    [[[GameModel myGame]myData].currentLineup fillGoalkeeper];
    [[[GameModel myGame]myData].currentLineup printFormation];
    
    XCTAssertTrue([[GameModel myGame]myData].currentLineup);

    for (int i =0;i<15;i++) {
        [[GameModel myGame]enterGame];
        NSLog(@"Next Match ID %i",[[GameModel myGame]myData].nextFixture.MATCHID);

        Match* playGame = [[GameModel myGame]myData].nextMatch;
        NSLog(@"Team %@-%@",playGame.team1.team.Name,playGame.team2.team.Name);

        XCTAssertTrue(playGame.team2);
        XCTAssertTrue([playGame.team1 validateTactic]);
        XCTAssertTrue([playGame.team2 validateTactic]);
        XCTAssertTrue([playGame startMatch]);
        
        
        while (!playGame.isOver && !playGame.isPaused) {
            //NSLog(@"%i",playGame.matchMinute);
            [playGame nextMinute];
        }
        
        playGame.isPaused = NO;
        
        while (!playGame.isOver && !playGame.isPaused) {
            //NSLog(@"%i",playGame.matchMinute);
            [playGame nextMinute];
        }
        
        NSLog(@"Score %i-%i",playGame.team1.score,playGame.team2.score);
        NSLog(@"Yellow %i-%i",playGame.team1.yellowCard,playGame.team2.yellowCard);
        NSLog(@"Red %i-%i",playGame.team1.redCard,playGame.team2.redCard);
        
        [[GameModel myGame]enterPreWeek];
        [[GameModel myGame]enterPreGame];
        [[GameModel myGame]enterGame];
    }

}


- (void)testGenerate
{
    
    Generator* newGenerator = [[Generator alloc]init];
    [newGenerator generateNewGameWithTeamName:@"TESTING UNITED"];
    
}

- (void)ttestDatabase
{
    NSArray* players = [[[DatabaseModel alloc]init]getArrayFrom:@"players" withSelectField:@"DISPLAYNAME" whereKeyField:@"PLAYERID" hasKey:@2];
    XCTAssertTrue([players count] == 1,@"get 1 player in players table");
    
}

- (void) ttestScout {
    Scout* newScout = [[Scout alloc]initWithScoutID:0];
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
    lineup.currentTactic = [[Tactic alloc]initWithTacticID:0];
    
    [lineup removeAllPlayers];
    [lineup fillGoalkeeper];
    [lineup fillOutfieldPlayers];
    [lineup printFormation];
    
    XCTAssertTrue([lineup validateTactic]);
    
    Team* opp = [[Team alloc]initWithTeamID:1];
    [opp updateFromDatabase];
    LineUp* oppLineup = [[LineUp alloc]initWithTeam:opp];
    oppLineup.currentTactic = [[Tactic alloc]initWithTacticID:2];
    [oppLineup removeAllPlayers];
    [oppLineup fillGoalkeeper];
    [oppLineup fillOutfieldPlayers];
    [oppLineup printFormation];
    XCTAssertTrue([oppLineup validateTactic]);
    
    
}

@end
