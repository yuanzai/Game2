//
//  Player.m
//  MatchEngine
//
//  Created by Junyuan Lau on 15/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//


#import "Player.h"
#import "GlobalVariableModel.h"
#import "DatabaseModel.h"
#import "GameModel.h"
#import "Tactic.h"
#import "Team.h"
#import "LineUp.h"

@implementation Player
@synthesize PlayerID;
@synthesize TeamID;
@synthesize DisplayName;
@synthesize LastName;
@synthesize FirstName;
@synthesize Stats;

@synthesize Consistency;
@synthesize Ability;
@synthesize Potential;
@synthesize Form;
@synthesize Condition;
@synthesize isInjured;

@synthesize PreferredPosition;
@synthesize TrainingID;
@synthesize StatBiasID;
@synthesize GrowthID;
@synthesize DecayID;
@synthesize DecayConstantID;
@synthesize BirthYear;
@synthesize TrainingExp;

@synthesize isGoalKeeper;
@synthesize Valuation;

@synthesize matchStats, PosCoeff, currentPositionSide, yellow, red, att, def, hasPlayed, lineup;

- (id) initWithPlayerID:(NSInteger) InputID {
	if (!(self = [super init]))
		return nil;
    NSDictionary* record = [[GameModel myDB]getResultDictionaryForTable:@"players" withKeyField:@"PlayerID" withKey:InputID];
    PlayerID = InputID;
    TeamID = [[record objectForKey:@"TEAMID"] integerValue];
    DisplayName= [record objectForKey:@"DISPLAYNAME"];
    LastName= [record objectForKey:@"LASTNAME"];
    FirstName= [record objectForKey:@"FIRSTNAME"];
    
    Ability = [[record objectForKey:@"ABILITY"] integerValue];
    Consistency = [[record objectForKey:@"CONSISTENCY"] integerValue];
    Potential = [[record objectForKey:@"POTENTIAL"] integerValue];
    Form = [[record objectForKey:@"FORM"] integerValue];
    Condition = [[record objectForKey:@"CONDITION"] doubleValue];
    
    Stats =[NSMutableDictionary dictionary];
    PreferredPosition = [NSMutableDictionary dictionary];
    if ([[record objectForKey:@"GK"] integerValue] == 1) {
        isGoalKeeper = YES;
        NSDictionary* gkrecord = [[GameModel myDB]getResultDictionaryForTable:@"players" withKeyField:@"PLAYERID" withKey:self.PlayerID];
        [[GlobalVariableModel gkStatList]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [Stats setObject:[gkrecord objectForKey:obj] forKey:obj];
        }];
        [PreferredPosition setObject:@"0" forKey:@"GK"];

    } else {
        isGoalKeeper = NO;
        [[GlobalVariableModel playerStatList] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [Stats setObject:[record objectForKey:obj] forKey:obj];
        }];
        [PreferredPosition setObject:[record objectForKey:@"LEFT"] forKey:@"LEFT"];
        [PreferredPosition setObject:[record objectForKey:@"RIGHT"] forKey:@"RIGHT"];
        [PreferredPosition setObject:[record objectForKey:@"CENTRE"] forKey:@"CENTRE"];
        [PreferredPosition setObject:[record objectForKey:@"DEF"] forKey:@"DEF"];
        [PreferredPosition setObject:[record objectForKey:@"DM"] forKey:@"DM"];
        [PreferredPosition setObject:[record objectForKey:@"MID"] forKey:@"MID"];
        [PreferredPosition setObject:[record objectForKey:@"AM"] forKey:@"AM"];
        [PreferredPosition setObject:[record objectForKey:@"SC"] forKey:@"SC"];
    }
    
    TrainingID = [[record objectForKey:@"TrainingID"] integerValue];
    StatBiasID = [[record objectForKey:@"StatBiasID"] integerValue];
    GrowthID = [[record objectForKey:@"GrowthID"] integerValue];
    DecayID = [[record objectForKey:@"DecayID"] integerValue];
    DecayConstantID = [[record objectForKey:@"DecayConstantID"] integerValue];
    BirthYear = [[record objectForKey:@"BirthYear"] integerValue];
    
    [TrainingExp setObject:[record objectForKey:@"DRILLSEXP"] forKey:@"DRILLSEXP"];
    [TrainingExp setObject:[record objectForKey:@"SHOOTINGEXP"] forKey:@"SHOOTINGEXP"];
    [TrainingExp setObject:[record objectForKey:@"PHYSICALEXP"] forKey:@"PHYSICALEXP"];
    [TrainingExp setObject:[record objectForKey:@"TACTICSEXP"] forKey:@"TACTICSEXP"];
    [TrainingExp setObject:[record objectForKey:@"SKILLSEXP"] forKey:@"SKILLSEXP"];
    
    Valuation = [[record objectForKey:@"VALUATION"] integerValue];
    if (Condition < 0.01)
        isInjured = YES;
    return self;
}

- (BOOL) updatePlayerInDatabaseStats:(BOOL) UpdateStats GameStat:(BOOL)UpdateGameStat Team: (BOOL) UpdateTeam Position: (BOOL) UpdatePosition Valuation:(BOOL) UpdateValuation
{
    NSMutableDictionary* updateDictionary = [[NSMutableDictionary alloc]init];
    
    if (UpdateTeam) {
        [updateDictionary setObject:[NSNumber numberWithInteger:TeamID] forKey:@"TeamID"];
    }
    
    if (UpdateGameStat) {
        [updateDictionary setObject:[NSNumber numberWithDouble:Condition] forKey:@"Condition"];
        [updateDictionary setObject:[NSNumber numberWithInteger:Form] forKey:@"Form"];
    }
    
    if (UpdateStats) {
        [updateDictionary addEntriesFromDictionary:Stats];
        __block NSInteger sumStat;
        [Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            sumStat += [obj integerValue];
        }];
        [updateDictionary setObject:@(sumStat) forKey:@"ABILITY"];
    }
    if (UpdatePosition) {
        [updateDictionary addEntriesFromDictionary:PreferredPosition];
    }
    if (UpdateValuation) {
        [updateDictionary setObject:[NSNumber numberWithInteger:Valuation] forKey:@"Valuation"];
    }
    
    [[GameModel myDB]updateDatabaseTable:@"players" withKeyField:@"PlayerID" withKey:PlayerID withDictionary:updateDictionary];
    return YES;
}

// TODO: Generate player in Player object instead
// TODO: GK Ability base to 400 instead

- (BOOL) valuePlayer
{

    //Value from Ability
    __block double sumStat = 0.0;
    [Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        sumStat += [(NSNumber*) obj integerValue];
    }];

    if (isGoalKeeper)
        sumStat = sumStat / (double)[[GlobalVariableModel gkStatList]count] * 20;
    
    Valuation = [self statValuation:sumStat];


    __block double coreStat = 0.0;
    __block double positionMultiplier = 1.0;
    
    if (isGoalKeeper) {
        coreStat = [self positionStatWithPosition:@"GK" Side:@"GK"];
    } else {
        
        NSDictionary* positionTable = [[NSDictionary alloc]initWithObjectsAndKeys:
                                       @1.0, @"DEF",
                                       @1.2,@"DM",
                                       @1.3,@"MID",
                                       @1.4,@"AM",
                                       @1.5,@"SC", nil];
        
        
        [positionTable enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([[PreferredPosition objectForKey:key]integerValue]==1) {
                if ([[PreferredPosition objectForKey:@"CENTRE"]integerValue]==1) {
                    NSInteger newStat = [self positionStatWithPosition:key Side:@"CENTRE"];
                    if (newStat >= coreStat)
                        positionMultiplier = [obj doubleValue];
                    coreStat = MAX(newStat,coreStat);
                }
                
                if ([[PreferredPosition objectForKey:@"LEFT"]integerValue]==1 ||
                    [[PreferredPosition objectForKey:@"RIGHT"]integerValue]==1) {
                    NSInteger newStat = [self positionStatWithPosition:key Side:@"CENTRE"];
                    if (newStat >= coreStat)
                        positionMultiplier = [obj doubleValue];
                    coreStat = MAX(newStat,coreStat);
                }
            }
        }];
    }
    
    Valuation += [self statValuation:coreStat]/2.5;
    
    NSInteger age = [[GameModel gameData]season] - BirthYear;
    double ageMultiplier = 0.0;
    
    if (age < 4) {
        ageMultiplier = .8;
    } else if (age< 6) {
        ageMultiplier = 1.0;
    } else if (age< 8) {
        ageMultiplier = 1.1;
    }else if (age< 12) {
        ageMultiplier = 1.2;
    }else if (age< 14) {
        ageMultiplier = 1.1;
    }else if (age< 16) {
        ageMultiplier = 1.0;
    }else if (age< 20) {
        ageMultiplier = .9;
    }else {
        ageMultiplier = .8;
    }
    Valuation *= ageMultiplier;
    Valuation *= positionMultiplier;
    
    return YES;
}

- (double) statValuation:(double) stat
{
    //stat has max 360
    return MIN(pow(10,(stat/100+1.8)),100000) + MAX(0,stat-320)*1000;
}

- (double) positionStatWithPosition:(NSString*)position Side:(NSString*) side
{
    __block double maxStat = 0.0;
    double statCount = [[GlobalVariableModel playerStatList]count];

    NSDictionary* valuationTable;
    if ([position isEqualToString:@"GK"]) {
        valuationTable = [[GlobalVariableModel myGlobalVariable] valuationStatListForFlank:@"GK"];
        statCount = [[GlobalVariableModel gkStatList]count];
    } else if ([[side uppercaseString] isEqualToString:@"CENTRE"]) {
        valuationTable = [[[GlobalVariableModel myGlobalVariable] valuationStatListForFlank:@"CENTRE"] objectForKey:position];
    } else {
        valuationTable = [[[GlobalVariableModel myGlobalVariable] valuationStatListForFlank:@"FLANK"] objectForKey:position];
    }
    
    [Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[valuationTable objectForKey:key]integerValue] == 1)
            maxStat +=  [obj doubleValue];
    }];
    
    return maxStat/statCount*20;
}
- (void) populateMatchStats
{
    if (!matchStats)
        matchStats = [[NSMutableDictionary alloc]init];
    
    [Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [matchStats setObject:[NSNumber numberWithDouble:[self getMatchStatWithBaseStat:[obj doubleValue] Consistency:(double) Consistency]] forKey:key];
    }];
    [[self getFormSet] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (Form > 0) {
            [matchStats setObject:MAX([matchStats objectForKey:obj],[NSNumber numberWithDouble:[self getMatchStatWithBaseStat:[obj doubleValue] Consistency:(double) Consistency]])  forKey:obj];
        } else {
            [matchStats setObject:MIN([matchStats objectForKey:obj],[NSNumber numberWithDouble:[self getMatchStatWithBaseStat:[obj doubleValue] Consistency:(double) Consistency]])  forKey:obj];
        }
    }];
    
    att = [self getEventStat:@"ATT"];
    def = [self getEventStat:@"DEF"];
}

- (void) populatePosCoeff
{
    PosCoeff = [self getPositionCoeffForPositionSide:currentPositionSide];
}


- (double) getPositionCoeffForPositionSide:(PositionSide) ps
{
    double result = 0.0;
    
    if ([[PreferredPosition objectForKey:[Structs getPositionString:ps]]integerValue] == 1) {
        result = 1;
    } else {
        if (ps.position == Def) {
            if ([[PreferredPosition objectForKey:@"DM"]integerValue]==1) {
                result = 0.9;
            } else {
                result = 0.8;
            }
        } else if (ps.position == SC) {
            if ([[PreferredPosition objectForKey:@"AM"]integerValue]==1) {
                result = 0.9;
            } else {
                result = 0.8;
            }
        } else {
            result = 0.95;
        }
    }
    
    NSInteger left =[[PreferredPosition objectForKey:@"LEFT"]integerValue];
    NSInteger right =[[PreferredPosition objectForKey:@"RIGHT"]integerValue];
    NSInteger centre =[[PreferredPosition objectForKey:@"CENTRE"]integerValue];
    
    if (ps.side == Left) {
        result +=(left-1) * 0.1;
    }else if (ps.side == LeftCentre){
        result += (centre-1) * 0.1;
        result += ((centre-1) * (left)) * 0.05;
    }else if (ps.side == Centre) {
        result += (centre-1) * 0.1;
    }else if (ps.side == RightCentre) {
        result += (centre-1) * 0.1;
        result += ((centre-1) * (right)) * 0.05;
    }else if (ps.side == Right) {
        result += (right-1) * 0.1;
    }
    return result;
}

- (double) getMatchStatWithBaseStat:(double)stat Consistency:(double) consistency{
    NSDictionary* sdTable = [[NSDictionary alloc]initWithDictionary:[[GlobalVariableModel myGlobalVariable] standardDeviationTable]];
    //normal dist 0 mean 1 sd
    double u =(double)(arc4random() %100000 + 1)/100000; //for precision
    double v =(double)(arc4random() %100000 + 1)/100000; //for precision
    double x = sqrt(-2*log(u))*cos(2*M_PI*v);   //or sin(2*pi*v)
    
    //stat constant
    double k2 = 0.05 * (double)consistency + 2 * stat -21;
    double mean = log(24.5 - stat);
    
    //stat sd
    double sd = [[sdTable objectForKey:[NSString stringWithFormat:@"%i",(int)stat]]doubleValue];
    
    //log normal X
    double matchStat = exp(mean + sd * x) + k2;
    matchStat = MAX(matchStat,1);
    matchStat = MIN(matchStat, 30);
    return matchStat;
}

- (NSArray*) getFormSet {
    NSMutableArray* tempArray = [[NSMutableArray alloc]initWithArray:[Stats allKeys]];
    
    int rollCount = Form * (3 + (isGoalKeeper ? -1 : 0));
    
    NSUInteger count = [tempArray count];
    for (uint i = 0; i < count; ++i)
    {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = arc4random_uniform(nElements) + i;
        [tempArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    NSMutableArray* formSet = [NSMutableArray array];
    for (int i = 0; i < ABS(rollCount); i++) {
        [formSet addObject:[tempArray objectAtIndex:i]];
    }
    return formSet;
}

- (double) getEventStat:(NSString*) type
{
    NSDictionary* eventStatsRecord = [[GameModel myDB] getResultDictionaryForTable:@"statsEvent" withDictionary:
                                      [[NSDictionary alloc]initWithObjectsAndKeys:
                                       type,@"TYPE",
                                       [Structs getPositionString:currentPositionSide],@"POSITION",
                                       [Structs getSideString:currentPositionSide],@"SIDE",nil]];
    
    __block double sum = 0.0;
    [matchStats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        sum += [[eventStatsRecord objectForKey:key]doubleValue]*[obj doubleValue];
    }];
    return sum;
}

- (BOOL) transferPlayerFromTeam:(Team*) fromTeam ToTeam:(Team*) toTeam Price:(NSInteger) price
{
    if ([GameModel gameData].money < price)
        return NO;

    [fromTeam.PlayerIDList removeObject:@(PlayerID)];
    [fromTeam.PlayerDictionary removeObjectForKey:[@(PlayerID) stringValue]];
    [fromTeam.PlayerList removeObject:self];
    
    [toTeam.PlayerIDList addObject:@(PlayerID)];
    [toTeam.PlayerDictionary setObject:self forKey:@(PlayerID)];
    [toTeam.PlayerList addObject:self];
    
    if (fromTeam.isSinglePlayer){
        [[GameModel gameData].myLineup removeInvalidPlayers];
        [GameModel gameData].money += price;
    } else if (toTeam.isSinglePlayer) {
        [GameModel gameData].money -= price;
    }
    return YES;
}

- (void) clearMatchVariable
{
    matchStats = nil;
    PosCoeff = 0.0;
    currentPositionSide = (PositionSide) {0,0};
    yellow = NO;
    red = NO;
    att = 0.0;
    def = 0.0;
    hasPlayed = NO;
}

- (BOOL) addToShortlist
{
    //TODO: add to shortlist
    return YES;
}

//TODO: PERKS
@end
