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
@synthesize WkOfBirth;
@synthesize TrainingExp;

@synthesize isGoalKeeper;


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
        NSDictionary* gkrecord = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"gk" withKeyField:@"PlayerID" withKey:self.PlayerID];
        [[GlobalVariableModel gkStatList]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [Stats setObject:[gkrecord objectForKey:obj] forKey:obj];
        }];
        
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
    WkOfBirth = [[record objectForKey:@"WkOfBirth"] integerValue];
    
    [TrainingExp setObject:[record objectForKey:@"DRILLSEXP"] forKey:@"DRILLSEXP"];
    [TrainingExp setObject:[record objectForKey:@"SHOOTINGEXP"] forKey:@"SHOOTINGEXP"];
    [TrainingExp setObject:[record objectForKey:@"PHYSICALEXP"] forKey:@"PHYSICALEXP"];
    [TrainingExp setObject:[record objectForKey:@"TACTICSEXP"] forKey:@"TACTICSEXP"];
    [TrainingExp setObject:[record objectForKey:@"SKILLSEXP"] forKey:@"SKILLSEXP"];
    
    if (Condition < 0.01)
        isInjured = YES;
    return self;
}

- (BOOL) updatePlayerInDatabaseStats:(BOOL) UpdateStats GameStat:(BOOL)UpdateGameStat Team: (BOOL) UpdateTeam Position: (BOOL) UpdatePosition{
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
    
    [[[DatabaseModel alloc]init]updateDatabaseTable:@"players" withKeyField:@"PlayerID" withKey:PlayerID withDictionary:updateDictionary];
    return YES;
}


@end
