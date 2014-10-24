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

@implementation Team
@synthesize TeamID;
@synthesize PlayerList;
@synthesize PlayerIDList;
@synthesize PlayerDictionary;
@synthesize tableData;
@synthesize isSinglePlayer;

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
    PlayerIDList = [[NSMutableArray alloc]initWithArray:[[[DatabaseModel alloc]init]getArrayFrom:@"players" withSelectField:@"PlayerID" whereKeyField:@"TeamID" hasKey:[NSNumber numberWithInteger:TeamID]]];
    tableData = [[NSMutableDictionary alloc]initWithDictionary:[[[DatabaseModel alloc]init]getResultDictionaryForTable:@"teams" withKeyField:@"TeamID" withKey:TeamID]];
    Name = [tableData objectForKey:@"NAME"];
    PlayerList = [[NSMutableArray alloc]init];
    PlayerDictionary = [NSMutableDictionary dictionary];

    [PlayerIDList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player* thisPlayer = [[Player alloc]initWithPlayerID:[obj integerValue]];
        [PlayerList addObject:thisPlayer];
        [PlayerDictionary setObject:thisPlayer forKey:[NSString stringWithFormat:@"%@",obj]];
    }];
}

- (BOOL) updateToDatabase
{
    return [[[DatabaseModel alloc]init]updateDatabaseTable:@"teams" withKeyField:@"TeamID" withKey:TeamID withDictionary:tableData];
}

- (Player*) getPlayerWithID:(NSInteger) PlayerID
{
    return [PlayerDictionary objectForKey:[NSString stringWithFormat:@"%i",PlayerID]];
}
@end
