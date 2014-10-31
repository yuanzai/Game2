//
//  Generator.m
//  MatchEngine
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Generator.h"
#import "DatabaseModel.h"
#import "Training.h"

@implementation Generator
{
    int playerCounter;
}
@synthesize FirstNames;
@synthesize LastNames;
@synthesize TeamNames;
@synthesize TeamNamesSuffix;
@synthesize AgeDistribution;



const NSInteger playerBatch = 330;
const NSInteger maxTurn = 16;

- (id) init {
	if (!(self = [super init]))
		return nil;
    FirstNames = [[DatabaseModel myDB]getArrayFrom:@"names" withSelectField:@"NAME" whereKeyField:@"TYPE" hasKey:@1];
    LastNames = [[DatabaseModel myDB]getArrayFrom:@"names" withSelectField:@"NAME" whereKeyField:@"TYPE" hasKey:@2];
    TeamNames = [[DatabaseModel myDB]getArrayFrom:@"names" withSelectField:@"NAME" whereKeyField:@"TYPE" hasKey:@3];
    TeamNamesSuffix = [[DatabaseModel myDB]getArrayFrom:@"names" withSelectField:@"NAME" whereKeyField:@"TYPE" hasKey:@4];
    AgeDistribution = [[DatabaseModel myDB]getArrayFrom:@"retire" withSelectField:@"AGEDISTRIBUTION" whereKeyField:@"" hasKey:nil];
    return self;
}

// New Game

- (void) generateNewGameWithTeamName:(NSString*) myTeamName
{
    [self generateNewTeamsWithTeamName:myTeamName];
    NSLog(@"New Teams");

    //[self generatePlayersForNewGame];
    NSLog(@"New Players");

    //[self assignPlayersToTeams];
    NSLog(@"New Assignments");

}

- (void) generateNewTeamsWithTeamName:(NSString*) myTeamName
{
    NSInteger myLeague = 81 + arc4random() % 4;
    
    [[DatabaseModel myDB]deleteFromTable:@"teams" withData:nil];
	NSArray* tournaments = [[DatabaseModel myDB]getArrayFrom:@"tournaments" whereData:nil sortFieldAsc:@""];
	[tournaments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* result = (NSDictionary*) obj;
        NSInteger teamCount = [[result objectForKey:@"TEAMCOUNT"]integerValue];
        
        for (NSInteger i = 0; i < teamCount; i++) {
            NSMutableDictionary* newTeam = [NSMutableDictionary dictionary];
        	NSString* teamName = [TeamNames objectAtIndex:arc4random() % [TeamNames count]];
        	if (arc4random() % 5 < 3) {
        		teamName = [NSString stringWithFormat:@"%@ %@",teamName, [TeamNamesSuffix objectAtIndex:arc4random() % [TeamNamesSuffix count]]];
        	}
            if ([[obj objectForKey:@"TOURNAMENTID"] integerValue] == myLeague && i == 0) {
                [newTeam setObject:myTeamName forKey:@"NAME"];
                [newTeam setObject:[obj objectForKey:@"TOURNAMENTID"] forKey:@"TOURNAMENTID"];
                [newTeam setObject:@0 forKey:@"TEAMID"];
            } else {
                [newTeam setObject:teamName forKey:@"NAME"];
                [newTeam setObject:[obj objectForKey:@"TOURNAMENTID"] forKey:@"TOURNAMENTID"];
            }
            [[DatabaseModel myDB]insertDatabaseTable:@"teams" withData:newTeam];
        }
    }];
}

- (void) generatePlayersForNewGame
{
    [[DatabaseModel myDB]deleteFromTable:@"players" withData:nil];

    [AgeDistribution enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self generatePlayersWithSeason:-idx+1 NumberOfPlayers:(NSInteger)(playerBatch * [obj doubleValue])];
    }];
    
}


- (void) assignPlayersToTeams
{
    /*
     0 - turn 0
     0 - turn 1
     1 - turn 0
     0 - turn 2
     1 - turn 1
     2 - turn 2
     */
    NSArray* teamList = [self getTeamsRankingArray];
    NSArray* teamGroup = [self getTeamsGrouping];
    NSArray* teamGroupCount = [self getTeamsGroupingCount];

    NSArray* playerList;
    
    for (NSInteger i = 0; i<[teamGroup count] + maxTurn;i++) {
        for (NSInteger j = maxTurn; j >= 0; j--){
            if (i-j >= 0 && i-j < [teamGroup count]) {
                if (j < maxTurn-1 || (j == maxTurn - 1 && i-j <11) || (j==maxTurn && i-j <4)) {
                    NSUInteger teamCount = [[teamGroupCount objectAtIndex:i-j]integerValue];
                    
                    playerList = [self distributePlayersTurn:j TeamsCount:teamCount];
                    [playerList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSMutableDictionary* updateDict = [NSMutableDictionary dictionary];
                        NSUInteger index = (idx % teamCount);
                        NSInteger teamListIndex =[[teamGroup objectAtIndex:i-j]integerValue] - index -1;
                        NSInteger teamID = [[teamList objectAtIndex:teamListIndex]integerValue];
                        [updateDict setObject:[NSNumber numberWithInteger:teamID]  forKey:@"TEAMID"];
                        
                        [[DatabaseModel myDB]updateDatabaseTable:@"players" withKeyField:@"PLAYERID" withKey:[obj integerValue] withDictionary:updateDict];
                        
                    }];
                }
            }
        }
    }
}


- (NSArray*) distributePlayersTurn:(NSInteger) turn TeamsCount:(NSInteger) teams{
    /*
     0 - 2	Top
     1 - 2  Top
     2 - 4	Def RLCC
     3 - 3	Mid RLC
     4 - 3	Mid RLC
     5 - 2	SC
     6 - 2	GK
     7 - 4	Top
     8 - 3	Rand
     9 - 3	Top
     10 - 4	Rand
     */
    NSMutableArray* result = [NSMutableArray array];
    switch (turn)
    
    {
        case 0:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams*2]]];
            break;
            
        case 1:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams*2]]];
            break;
        case 2:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND DEF=1 AND LEFT=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams]]];
            break;
        case 3:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND DEF=1 AND CENTRE=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams*2]]];
            break;
        case 4:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND DEF=1 AND RIGHT=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams]]];
            break;
        case 5:
        case 8:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND (DM=1 OR MID=1 OR AM=1) AND LEFT=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams]]];
            break;
            
        case 6:
        case 9:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND (DM=1 OR MID=1 OR AM=1) AND RIGHT=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams]]];
            break;
            
        case 7:
        case 10:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND (DM=1 OR MID=1 OR AM=1) AND CENTRE=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams]]];
            break;
        case 11:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND SC=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams*2]]];
            break;
        case 12:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1 AND GK=1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams*2]]];
            break;
        case 13:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams*4]]];
            break;
        case 14:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1" OrderBy:@"RANDOM()" Limit:[NSString stringWithFormat:@"%i",teams*4]]];
            break;
        case 15:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1" OrderBy:@"VALUATION DESC" Limit:[NSString stringWithFormat:@"%i",teams*2]]];
            break;
        case 16:
            [result addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" WhereString:@"TEAMID = -1" OrderBy:@"RANDOM()" Limit:[NSString stringWithFormat:@"%i",teams*4]]];
            break;
            
        default:
            result = nil;
            break;
            
    }
    
    return [self shuffleArray:result];
}
   
- (NSArray*) getTeamsGroupingCount {
    return [[NSArray alloc]initWithObjects:
            @4,@4,@4,@4,@4,@4,@4,@4,@4,@4,
            @8,@8,@8,@8,@8,@8,@8,@8,@8,@8,
            @16,@16,@16,@16,@16,nil];
}

- (NSArray*) getTeamsGrouping {
    return [[NSArray alloc]initWithObjects:
            @4,@8,@12,@16,@20,@24,@28,@32,@36,
            @40,@48,@56,@64,@72,@80,@88,@96,@104,@112,
            @120,@136,@152,@168,@184,@200,nil];
}

- (NSArray*) getTeamsRankingArray {
    NSMutableArray* fullArray = [NSMutableArray array];
    for (NSInteger i = 1; i <9; i++) {
        NSMutableArray* teamsArray = [NSMutableArray array];
        for (NSInteger j = 1; j < 10 ; j++){
            [teamsArray addObjectsFromArray:[[DatabaseModel myDB]getArrayFrom:@"teams" withSelectField:@"TEAMID" whereKeyField:@"TOURNAMENTID" hasKey:[NSNumber numberWithInteger:i*10+j]]];
        }
        [fullArray addObjectsFromArray:[self shuffleArray:teamsArray]];
    }
    return fullArray;
}

- (void) generatePlayersForNewSeason
{
// TODO    
}



// Continuing

- (void) generatePlayersWithSeason:(NSInteger) season NumberOfPlayers:(NSInteger) number
{
    GeneratePlayer* newPlayer;
    for (int i = 0; i < number; i ++) {
        newPlayer = [[GeneratePlayer alloc]init];
        newPlayer.FirstNames = FirstNames;
        newPlayer.LastNames = LastNames;
        NSInteger potential = [self generatePotential];
        NSInteger ability = 100 + [self generateAbilityCoefficient] * MAX(potential * 2 + 160 - 100,100);
        
        [newPlayer createPlayerWithAbility:ability Potential:potential Season:season];
        playerCounter++;
    }
}

- (NSInteger) generatePotential
{
    NSInteger r = arc4random() % 1000;
    NSInteger potential;
    if (r < 160) {
        potential = 0;
    } else if (r < 363) {
        potential = 10;
    } else if (r < 501) {
        potential = 20;
    } else if (r < 630) {
        potential = 30;
    } else if (r < 738) {
        potential = 40;
    } else if (r < 834) {
        potential = 50;
    } else if (r < 910) {
        potential = 60;
    } else if (r < 965) {
        potential = 70;
    } else if (r < 988) {
        potential = 80;
    } else {
        potential = 90;
    }
    
    potential += 1 + arc4random() % 10;
    return potential;
}


- (double) generateAbilityCoefficient
{
    NSInteger r = arc4random() % 100;
    double abilityCoEff;
    if (r < 40) {
        abilityCoEff = 0.0;
    } else if (r < 65) {
        abilityCoEff = .2;
    } else if (r < 85) {
        abilityCoEff = .4;
    } else if (r < 97) {
        abilityCoEff = .6;
    } else {
        abilityCoEff = .8;
    }
    
    abilityCoEff += (arc4random() % 20) / 100;
    return  abilityCoEff;
}

- (NSArray*) getArrayOfNumbers:(NSInteger)count Min:(NSInteger)min Max:(NSInteger) max
{
    NSInteger counter = count;
    NSMutableArray* workingArray = [NSMutableArray array];
    NSMutableArray* tempArray = [NSMutableArray array];

    for (NSInteger i = min; i <= max; i++) {
        [workingArray addObject:[NSNumber numberWithInteger:i]];
    }
    
    for (NSInteger i = 0; i < count; i++) {
        NSInteger r = arc4random() % counter;
        [tempArray addObject:[workingArray objectAtIndex:r]];
        [workingArray removeObjectAtIndex:r];
        counter--;
    }
    return tempArray;
}

- (NSArray*) shuffleArray:(NSArray*) arrayInput{
    NSMutableArray* tempArray = [[NSMutableArray alloc]initWithArray:arrayInput];
    for (NSInteger i = 0; i < [tempArray count]; ++i) {
        [tempArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % [tempArray count]];
    }
    return tempArray;
}

@end


@implementation GeneratePlayer
@synthesize FirstNames;
@synthesize LastNames;

const NSInteger growthMax = 1;
const NSInteger decayMax = 1;
const NSInteger decayKMax = 1;
const NSInteger statBiasMax = 63;

- (BOOL) createPlayerWithAbility:(NSInteger)ability Potential:(NSInteger) potential Season:(NSInteger) season
{
    NSMutableDictionary* newPlayer = [NSMutableDictionary dictionary];
    [newPlayer setObject:[NSNumber numberWithInteger:potential] forKey:@"potential"];
    self.potential = potential;
    
    //Profiles
    StatBiasID = (arc4random() % statBiasMax) + 1;
    GrowthID = (arc4random() % growthMax) + 1;
    DecayConstantID = (arc4random() % decayKMax) + 1;
    DecayID = (arc4random() % decayMax) + 1;
    [newPlayer setObject:[NSNumber numberWithInteger:StatBiasID] forKey:@"StatBiasID"];
    [newPlayer setObject:[NSNumber numberWithInteger:GrowthID] forKey:@"GrowthID"];
    [newPlayer setObject:[NSNumber numberWithInteger:DecayConstantID] forKey:@"DecayConstantID"];
    [newPlayer setObject:[NSNumber numberWithInteger:DecayID] forKey:@"DecayID"];
    
    //Side
    /*
     C 22
     LC 17
     RC 17
     RLC 5
     LR 5
     L 17
     R 17
     */
    NSInteger r = arc4random() % 100;
    if (!PreferredPosition)
        PreferredPosition = [NSMutableDictionary dictionary];
    
    if (r < 22) {
        [PreferredPosition setObject:@0 forKey:@"RIGHT"];
        [PreferredPosition setObject:@1 forKey:@"CENTRE"];
        [PreferredPosition setObject:@0 forKey:@"LEFT"];
    } else if (r < 39) {
        [PreferredPosition setObject:@1 forKey:@"RIGHT"];
        [PreferredPosition setObject:@1 forKey:@"CENTRE"];
        [PreferredPosition setObject:@0 forKey:@"LEFT"];
    } else if (r < 56) {
        [PreferredPosition setObject:@0 forKey:@"RIGHT"];
        [PreferredPosition setObject:@1 forKey:@"CENTRE"];
        [PreferredPosition setObject:@1 forKey:@"LEFT"];
    } else if (r < 61) {
        [PreferredPosition setObject:@1 forKey:@"RIGHT"];
        [PreferredPosition setObject:@1 forKey:@"CENTRE"];
        [PreferredPosition setObject:@1 forKey:@"LEFT"];
    } else if (r < 66) {
        [PreferredPosition setObject:@1 forKey:@"RIGHT"];
        [PreferredPosition setObject:@0 forKey:@"CENTRE"];
        [PreferredPosition setObject:@1 forKey:@"LEFT"];
    } else if (r < 83) {
        [PreferredPosition setObject:@1 forKey:@"RIGHT"];
        [PreferredPosition setObject:@0 forKey:@"CENTRE"];
        [PreferredPosition setObject:@0 forKey:@"LEFT"];
    } else {
        [PreferredPosition setObject:@0 forKey:@"RIGHT"];
        [PreferredPosition setObject:@0 forKey:@"CENTRE"];
        [PreferredPosition setObject:@1 forKey:@"LEFT"];
    }
    
    //Position
    /*
     D - 23
     D DM - 13
     D M - 5
     D AM - 2
     D S - 1
     DM - 7
     M - 8
     AM - 7
     DM S - 1
     M S - 2
     AM S - 13
     S - 18
     */
    r = arc4random() % 100;
    
    [PreferredPosition setObject:@0 forKey:@"DEF"];
    [PreferredPosition setObject:@0 forKey:@"DM"];
    [PreferredPosition setObject:@0 forKey:@"MID"];
    [PreferredPosition setObject:@0 forKey:@"AM"];
    [PreferredPosition setObject:@0 forKey:@"SC"];
    
    
    if (r < 11) {
        [PreferredPosition setObject:@1 forKey:@"GK"];
        [PreferredPosition setObject:@0 forKey:@"RIGHT"];
        [PreferredPosition setObject:@0 forKey:@"CENTRE"];
        [PreferredPosition setObject:@0 forKey:@"LEFT"];
        isGoalKeeper = YES;
    } else if (r < 31) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
    } else if (r < 43) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"DM"];
    } else if (r < 48) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"MID"];
    } else if (r < 50) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"AM"];
    } else if (r < 51) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else if (r < 57) {
        [PreferredPosition setObject:@1 forKey:@"DM"];
    } else if (r < 64) {
        [PreferredPosition setObject:@1 forKey:@"MID"];
    } else if (r < 70) {
        [PreferredPosition setObject:@1 forKey:@"AM"];
    } else if (r < 71) {
        [PreferredPosition setObject:@1 forKey:@"DM"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else if (r < 73) {
        [PreferredPosition setObject:@1 forKey:@"MID"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else if (r < 84) {
        [PreferredPosition setObject:@1 forKey:@"AM"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else {
        [PreferredPosition setObject:@1 forKey:@"SC"];
        
        [PreferredPosition setObject:@0 forKey:@"RIGHT"];
        [PreferredPosition setObject:@1 forKey:@"CENTRE"];
        [PreferredPosition setObject:@0 forKey:@"LEFT"];
    }
    [newPlayer addEntriesFromDictionary:PreferredPosition];
    
    //Name
    FirstName = [FirstNames objectAtIndex:arc4random() % [FirstNames count]];
    LastName = [LastNames objectAtIndex:arc4random() % [LastNames count]];
    DisplayName = LastName;
    [newPlayer setObject:FirstName forKey:@"FirstName"];
    [newPlayer setObject:LastName forKey:@"LastName"];
    [newPlayer setObject:DisplayName forKey:@"DisplayName"];

    //WkOfBirth
    BirthYear =  season;
    [newPlayer setObject:[NSNumber numberWithInteger:BirthYear] forKey:@"BirthYear"];

    //Stats
    
    Stats = [NSMutableDictionary dictionary];
    [[GlobalVariableModel playerStatList]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [Stats setObject:@1 forKey:obj];
    }];
    
    for (NSInteger i = 0; i < ability - 20; i++) {
        r = arc4random() % 20;
        NSInteger stat = [[Stats objectForKey:[[GlobalVariableModel playerStatList]objectAtIndex:r]]integerValue];
        if (stat == 20) {
            i--;
        } else {
            [Stats setObject:[NSNumber numberWithInteger:stat+1] forKey:[[GlobalVariableModel playerStatList]objectAtIndex:r]];
        }
    }
    
    Plan* newPlayerTraining = [[Plan alloc]initWithPotential:potential Age:1-BirthYear];
    
    for (NSInteger i = BirthYear; i<1; i ++){
        [newPlayerTraining runTrainingPlanForPlayer:self Times:5 ExpReps:17 Season:i];
    }

    
    [newPlayer addEntriesFromDictionary:Stats];
    
    //TEAMID
    TeamID = -1;
    [newPlayer setObject:[NSNumber numberWithInteger:TeamID] forKey:@"TeamID"];
    
    
    //Consistency
    Consistency = arc4random() % 17 + arc4random() % 4 + 1;
    [newPlayer setObject:[NSNumber numberWithInteger:Consistency] forKey:@"Consistency"];
    
    
    //Condition + Form
    Condition = 1;
    [newPlayer setObject:[NSNumber numberWithDouble:Condition] forKey:@"Condition"];
    
    Form = 1;
    [newPlayer setObject:[NSNumber numberWithDouble:Form] forKey:@"Form"];
    [self valuePlayer];
    
    [newPlayer setObject:[NSNumber numberWithDouble:Valuation] forKey:@"Valuation"];
    
    return [[DatabaseModel myDB]insertDatabaseTable:@"players" withData:newPlayer];
}
@end
