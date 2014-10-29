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

@implementation Player
@synthesize PlayerID;
@synthesize TeamID;
@synthesize DisplayName;
@synthesize LastName;
@synthesize FirstName;
@synthesize Stats;

@synthesize Consistency;
@synthesize Potential;
@synthesize Form;
@synthesize Condition;

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

- (id) initWithPlayerID:(NSInteger) InputID {
	if (!(self = [super init]))
		return nil;
    NSDictionary* record = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"players" withKeyField:@"PlayerID" withKey:InputID];
    PlayerID = InputID;
    TeamID = [[record objectForKey:@"TeamID"] integerValue];
    DisplayName= [record objectForKey:@"DisplayName"];
    LastName= [record objectForKey:@"LastName"];
    FirstName= [record objectForKey:@"FirstName"];
    
    
    Consistency = [[record objectForKey:@"Consistency"] integerValue];
    Potential = [[record objectForKey:@"Potential"] integerValue];
    Form = [[record objectForKey:@"Form"] integerValue];
    Condition = [[record objectForKey:@"Condition"] doubleValue];
    
    if ([[record objectForKey:@"GK"] integerValue] == 1) {
        isGoalKeeper = YES;
        NSDictionary* gkrecord = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"players" withKeyField:@"PlayerID" withKey:self.PlayerID];
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
    
    Valuation = [[record objectForKey:@"Valuation"] integerValue];
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
        if (isGoalKeeper){
            [[[DatabaseModel alloc]init]updateDatabaseTable:@"gk" withKeyField:@"PlayerID" withKey:PlayerID withDictionary:Stats];
        }else{
            [updateDictionary addEntriesFromDictionary:Stats];
        }
    }
    if (UpdatePosition) {
        [updateDictionary addEntriesFromDictionary:PreferredPosition];
    }
    if (UpdateValuation) {
        [updateDictionary setObject:[NSNumber numberWithInteger:Valuation] forKey:@"Valuation"];
    }
    
    [[[DatabaseModel alloc]init]updateDatabaseTable:@"players" withKeyField:@"PlayerID" withKey:PlayerID withDictionary:updateDictionary];
    return YES;
}

- (BOOL) valuePlayer
{

    //Value from Ability
    __block NSInteger sumStat = 0;
    [Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        sumStat += [(NSNumber*) obj integerValue];
    }];

    if (isGoalKeeper)
        sumStat = sumStat / [[GlobalVariableModel gkStatList]count] * 20;
    
    Valuation = [self statValuation:sumStat];
    //NSLog(@"%f",Valuation);
    __block NSInteger coreStat = 0;
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

- (NSInteger) positionStatWithPosition:(NSString*)position Side:(NSString*) side
{
    __block double maxStat = 0.0;
    NSDictionary* valuationTable;
    if ([position isEqualToString:@"GK"]) {
        valuationTable = [GlobalVariableModel valuationStatListForFlank:@"GK"];
    } else if ([[side uppercaseString] isEqualToString:@"CENTRE"]) {
        valuationTable = [[GlobalVariableModel valuationStatListForFlank:@"CENTRE"] objectForKey:position];
    } else {
        valuationTable = [[GlobalVariableModel valuationStatListForFlank:@"FLANK"] objectForKey:position];
    }
    
    [Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[valuationTable objectForKey:key]integerValue] == 1)
            maxStat +=  [obj doubleValue];
    }];
    
    return maxStat/[valuationTable count]*[Stats count];
}
@end
