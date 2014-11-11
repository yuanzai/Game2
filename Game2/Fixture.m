//
//  Fixture.m
//  MatchEngine
//
//  Created by Junyuan Lau on 29/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Fixture.h"
#import "DatabaseModel.h"
#import "Team.h"
#import "GameModel.h"

@implementation Tournament
@synthesize tournamentName;
@synthesize tournamentID;
@synthesize tournamentType;
@synthesize teamCount;
@synthesize promoteToTournament;
@synthesize relegateToTournament;
@synthesize promoteCount;
@synthesize relegateCount;
@synthesize playerCount;

- (id) initWithTournamentID:(NSInteger) TournamentID
{
    self = [super init];
    if (self) {
        self.tournamentID = TournamentID;
        NSDictionary* record = [[DatabaseModel myDB]getResultDictionaryForTable:@"tournaments" withKeyField:@"TournamentID" withKey:tournamentID];
        tournamentName = [record objectForKey:@"NAME"];
        tournamentType = [record objectForKey:@"TYPE"];
        teamCount = [[record objectForKey:@"TEAMCOUNT"]integerValue];
        promoteToTournament = [[record objectForKey:@"PROMOTETO"]integerValue];
        relegateToTournament = [[record objectForKey:@"RELEGATETO"]integerValue];
        promoteCount = [[record objectForKey:@"PROMOTECOUNT"]integerValue];
        relegateCount = [[record objectForKey:@"RELEGATECOUNT"]integerValue];
        playerCount =[[record objectForKey:@"PLAYERCOUNT"]integerValue];
    }
    return self;
}

- (BOOL) createFixturesForSeason:(NSInteger)season
{
    NSMutableArray* teamsArray = [[NSMutableArray alloc]initWithArray:[[DatabaseModel myDB]getArrayFrom:@"teams" withSelectField:@"TEAMID" whereKeyField:@"TOURNAMENTID" hasKey:[NSNumber numberWithInteger:tournamentID]]];
    
    if ([teamsArray count] != teamCount)
        return NO;
    
    //shuffle
    for (NSInteger i = 0; i < [teamsArray count]; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = [teamsArray count] - i;
        NSInteger n = (arc4random() % nElements) + i;
        [teamsArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    NSMutableArray* genericList = [NSMutableArray array];
    NSMutableArray* homeList = [NSMutableArray array];
    NSMutableArray* awayList = [NSMutableArray array];
    
    for (NSInteger i = 1; i < [teamsArray count]; i++) {
        [genericList addObject:[NSNumber numberWithInteger:i]];
    }
    
    for (NSInteger round = 0; round < [teamsArray count]-1; round++) {
        for (NSInteger i = 0; i < [teamsArray count]/2;i++){
            NSInteger home;
            NSInteger away;
            
            if (i ==0) {
                home = 0;
                away = [[genericList objectAtIndex:0]integerValue];
            } else {
                home = [[genericList objectAtIndex:i]integerValue];
                away = [[genericList objectAtIndex:[teamsArray count] - 1 - i]integerValue];
            }
            if (arc4random()%2 ==0){
                NSInteger temp = home;
                home = away;
                away = temp;
            }
            
            [homeList addObject:[NSNumber numberWithInt:home]];
            [awayList addObject:[NSNumber numberWithInt:away]];
        }
        NSNumber* temp = [genericList objectAtIndex:0];
        [genericList removeObjectAtIndex:0];
        [genericList addObject:temp];
    }
    
    NSInteger k = 0;
    for (NSInteger round = 0; round < [teamsArray count]-1; round++) {
        for (NSInteger i = 0; i < [teamsArray count]/2;i++){
            NSInteger date = (season-1) * 52 + round + 1;
            NSDictionary* data =
            [[NSDictionary alloc]
             initWithObjectsAndKeys:
             [NSNumber numberWithInteger:tournamentID],@"TOURNAMENTID",
             [NSNumber numberWithInteger:season],@"SEASON",
             [NSNumber numberWithInteger:date],@"DATE",
             [NSNumber numberWithInteger:round + 1],@"ROUND",
             [teamsArray objectAtIndex:[[homeList objectAtIndex:k]integerValue]],@"HOMETEAM",
             [teamsArray objectAtIndex:[[awayList objectAtIndex:k]integerValue]],@"AWAYTEAM",
             @"HOME",@"HOMELOGJSON",
             @"AWAY",@"AWAYLOGJSON",
             nil];
            [[DatabaseModel myDB]insertDatabaseTable:@"fixtures" withData:data];
            k++;
        }
    }
    
    for (NSInteger i = 0; i < [teamsArray count]/2; ++i) {
        NSInteger nElements = [teamsArray count]/2 - i;
        NSInteger n = (arc4random() % nElements) + i;
        //shuffle 2nd half part 1
        [awayList exchangeObjectAtIndex:i withObjectAtIndex:n];
        [homeList exchangeObjectAtIndex:i withObjectAtIndex:n];
        
        nElements = [teamsArray count]/2 - i;
        n = (arc4random() % nElements) + i;
        //shuffle 2nd half part 2
        [awayList exchangeObjectAtIndex:i+[teamsArray count]/2 withObjectAtIndex:n+[teamsArray count]/2];
        [homeList exchangeObjectAtIndex:i+[teamsArray count]/2 withObjectAtIndex:n+[teamsArray count]/2];
    }
    
    k = 0;
    
    for (NSInteger round = [teamsArray count] -1; round < ([teamsArray count]-1)*2; round++) {
        for (NSInteger i = 0; i < [teamsArray count]/2;i++){
            NSInteger date = (season-1) * 52 + round + 1;
            NSDictionary* data =
            [[NSDictionary alloc]
             initWithObjectsAndKeys:
             [NSNumber numberWithInteger:tournamentID],@"TOURNAMENTID",
             [NSNumber numberWithInteger:season],@"SEASON",
             [NSNumber numberWithInteger:date],@"DATE",
             [NSNumber numberWithInteger:round + 1],@"ROUND",
             [teamsArray objectAtIndex:[[awayList objectAtIndex:k]integerValue]],@"HOMETEAM",
             [teamsArray objectAtIndex:[[homeList objectAtIndex:k]integerValue]],@"AWAYTEAM",
             @"HOME",@"HOMELOGJSON",
             @"AWAY",@"AWAYLOGJSON",
             nil];
            [[DatabaseModel myDB]insertDatabaseTable:@"fixtures" withData:data];
            k++;

        }
    }
    
    return YES;
}
- (NSArray*) getAllFixturesForSeason:(NSInteger)season;
{
    return [[DatabaseModel myDB]getArrayFrom:@"fixtures" whereData:[[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:tournamentID],@"TOURNAMENTID", [NSNumber numberWithInteger:season],@"SEASON", nil] sortFieldAsc:@"DATE"];
}

- (NSArray*) getFixturesForTeam:(Team*) team ForSeason:(NSInteger)season Remaining:(BOOL) remainingOnly
{
    NSArray* homeArray = [[DatabaseModel myDB]getArrayFrom:@"fixtures" whereData:
            [[NSDictionary alloc]initWithObjectsAndKeys:
             [NSNumber numberWithInteger:tournamentID],@"TOURNAMENTID",
             [NSNumber numberWithInteger:season],@"SEASON",
             [NSNumber numberWithInteger:team.TeamID],@"HOMETEAM", nil] sortFieldAsc:@"DATE"];

    NSArray* awayArray = [[DatabaseModel myDB]getArrayFrom:@"fixtures" whereData:
                          [[NSDictionary alloc]initWithObjectsAndKeys:
                           [NSNumber numberWithInteger:tournamentID],@"TOURNAMENTID",
                           [NSNumber numberWithInteger:season],@"SEASON",
                           [NSNumber numberWithInteger:team.TeamID],@"AWAYTEAM", nil] sortFieldAsc:@"DATE"];
    
    NSMutableArray* bothArray = [[NSMutableArray alloc] initWithArray:homeArray];
    [bothArray addObjectsFromArray:awayArray];
    NSArray* ret = [bothArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger aDate = [[obj1 objectForKey:@"DATE"]integerValue];
        NSInteger bDate = [[obj2 objectForKey:@"DATE"]integerValue];
        if (aDate < bDate) {
            return NSOrderedAscending;
        } else if (aDate > bDate) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return ret;
}

- (void) getPromotionAndRelegationForSeason:(NSInteger) season
{
    //TODO: promotion relegation at end of season
}

-(NSArray*) getLeagueTableForSeason:(NSInteger)season
{
    return [[DatabaseModel myDB]getLeagueTableForTournamentID:tournamentID Season:season];
}

- (Fixture*) getMatchForTeamID:(NSInteger) teamID Date:(NSInteger) date
{
    NSDictionary* result = [[DatabaseModel myDB]
                            getResultDictionaryForTable:@"fixtures"
                            withDictionary:[[NSDictionary alloc]
                                            initWithObjectsAndKeys:@(teamID),@"HOMETEAM",
                                            @(date),@"DATE",
                                            nil]];
    if (!result)
        result =[[DatabaseModel myDB]
                 getResultDictionaryForTable:@"fixtures"
                 withDictionary:[[NSDictionary alloc]
                                 initWithObjectsAndKeys:@(teamID),@"AWAYTEAM",
                                 @(date),@"DATE",
                                 nil]];
    NSInteger matchID = [[result objectForKey:@"MATCHID"]integerValue];
    return [[Fixture alloc]initWithMatchID:matchID];
}
@end

@implementation Fixture
@synthesize MATCHID;
@synthesize TOURNAMENTID;
@synthesize SEASON;
@synthesize DATE;
@synthesize ROUND;
@synthesize HOMETEAM;
@synthesize AWAYTEAM;
@synthesize HOMESCORE;
@synthesize AWAYSCORE;
@synthesize HOMEYELLOW;
@synthesize HOMERED;
@synthesize AWAYYELLOW;
@synthesize AWAYRED;
@synthesize HASET;
@synthesize PLAYEDET;
@synthesize HASPENALTIES;
@synthesize PLAYEDPENALTIES;
@synthesize HOMEPENALTIES;
@synthesize AWAYPENALTIES;
@synthesize HOMELOGJSON;
@synthesize AWAYLOGJSON;
@synthesize PLAYED;

- (id) initWithMatchID:(NSInteger) thisMatchID
{
    self = [super init];
    if (self) {
        NSDictionary* result = [[DatabaseModel myDB]getResultDictionaryForTable:@"fixtures" withKeyField:@"MATCHID" withKey:thisMatchID];
        [result enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self setValuesForKeysWithDictionary:result];
        }];
    }
    return self;
}

//TODO: update fixture
-(void) updateFixtureInDatabase
{
    // todo
}
@end
