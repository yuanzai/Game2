//
//  Team.m
//  MatchEngine
//
//  Created by Junyuan Lau on 17/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Team.h"
#import "GlobalVariableModel.h"
#import "DatabaseModel.h"
#import "Player.h"
#import "GameModel.h"


@implementation Team
@synthesize TeamID;
@synthesize Name;
@synthesize TournamentID;
@synthesize PlayerList;
@synthesize PlayerIDList;
@synthesize PlayerDictionary;
@synthesize isSinglePlayer;
@synthesize leagueTournament;

- (id) initWithTeamID:(NSInteger) InputID
{
	if (!(self = [super init]))
		return nil;
    TeamID = InputID;
    isSinglePlayer = (TeamID == 0);
    [self updateFromDatabase];
    return self;
}

- (void) updateFromDatabase
{
    PlayerIDList = [[NSMutableSet alloc]initWithArray:[[GameModel myDB]getArrayFrom:@"players" withSelectField:@"PlayerID" whereKeyField:@"TeamID" hasKey:[NSNumber numberWithInteger:TeamID]]];
    
    GameModel* myGame = [GameModel myGame];
    NSDictionary* result = [myGame.myDB getResultDictionaryForTable:@"teams" withKeyField:@"TeamID" withKey:TeamID];
    
    Name = [result objectForKey:@"NAME"];
    TournamentID = [[result objectForKey:@"TOURNAMENTID"]integerValue];
    leagueTournament = [[myGame.myGlobalVariableModel tournamentList]objectForKey:[@(TournamentID) stringValue]];
    
    PlayerList = [[NSMutableArray alloc]init];
    PlayerDictionary = [NSMutableDictionary dictionary];

    [PlayerIDList enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Player* thisPlayer = [[[GameModel myGlobalVariableModel]playerList]objectForKey:[NSString stringWithFormat:@"%@",obj]];
        [PlayerList addObject:thisPlayer];
        [PlayerDictionary setObject:thisPlayer forKey:[obj stringValue]];
    }];
}


- (BOOL) updateToDatabase
{
    NSMutableDictionary* updateData = [NSMutableDictionary dictionary];
    [updateData setObject:@(TournamentID) forKey:@"TOURNAMENTID"];
    return [[GameModel myDB]updateDatabaseTable:@"teams" withKeyField:@"TeamID" withKey:TeamID withDictionary:updateData];
}

- (Player*) getPlayerWithID:(NSInteger) PlayerID
{
    return [PlayerDictionary objectForKey:[NSString stringWithFormat:@"%i",PlayerID]];
}

- (void) updateConditionPreGame
{
//TODO update condition method
}

- (void) transferActivity
{
    //TODO transfer activity
}
@end
