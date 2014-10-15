//
//  Generator.m
//  MatchEngine
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Generator.h"
#import "DatabaseModel.h"

@implementation Generator
@synthesize FirstNames;
@synthesize LastNames;
const NSInteger playerBatch = 360;

- (id) init {
	if (!(self = [super init]))
		return nil;
    FirstNames = [[[DatabaseModel alloc]init]getArrayFrom:@"names" withSelectField:@"NAME" whereKeyField:@"TYPE" hasKey:1];
    LastNames = [[[DatabaseModel alloc]init]getArrayFrom:@"names" withSelectField:@"NAME" whereKeyField:@"TYPE" hasKey:2];
 
    return self;
}

- (void) generatePlayersForNewSeason
{
    
}

- (void) generatePlayersForNewGame
{
    
}

- (void) generatePlayersWithSeason:(NSInteger) season
{
    
    for (int i = 0; i < playerBatch; i ++) {
        GeneratePlayer* newPlayer = [[GeneratePlayer alloc]init];
        newPlayer.FirstNames = FirstNames;
        newPlayer.LastNames = LastNames;
        NSInteger potential = [self generatePotential];
        NSInteger ability = 100 + [self generateAbilityCoefficient] * MAX(potential * 2 + 160 - 100,100);
        
        [newPlayer createPlayerWithAbility:ability Potential:potential Season:season];
    }
}

- (NSInteger) generatePotential
{
    NSInteger r = arc4random() % 1000;
    NSInteger potential;
    if (r < 210) {
        potential = 0;
    } else if (r < 393) {
        potential = 10;
    } else if (r < 551) {
        potential = 20;
    } else if (r < 680) {
        potential = 30;
    } else if (r < 778) {
        potential = 40;
    } else if (r < 864) {
        potential = 50;
    } else if (r < 936) {
        potential = 60;
    } else if (r < 982) {
        potential = 70;
    } else if (r < 996) {
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
    
    
    if (r < 23) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
    } else if (r < 36) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"DM"];
    } else if (r < 41) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"MID"];
    } else if (r < 43) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"AM"];
    } else if (r < 44) {
        [PreferredPosition setObject:@1 forKey:@"DEF"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else if (r < 51) {
        [PreferredPosition setObject:@1 forKey:@"DM"];
    } else if (r < 59) {
        [PreferredPosition setObject:@1 forKey:@"MID"];
    } else if (r < 66) {
        [PreferredPosition setObject:@1 forKey:@"AM"];
    } else if (r < 67) {
        [PreferredPosition setObject:@1 forKey:@"DM"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else if (r < 69) {
        [PreferredPosition setObject:@1 forKey:@"MID"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else if (r < 82) {
        [PreferredPosition setObject:@1 forKey:@"AM"];
        [PreferredPosition setObject:@1 forKey:@"SC"];
    } else {
        [PreferredPosition setObject:@1 forKey:@"SC"];
        
        [PreferredPosition setObject:@0 forKey:@"RIGHT"];
        [PreferredPosition setObject:@1 forKey:@"CENTRE"];
        [PreferredPosition setObject:@0 forKey:@"LEFT"];
    }
    [newPlayer addEntriesFromDictionary:PreferredPosition];
    
    
    //Stats
    
    Stats = [NSMutableDictionary dictionary];
    [[GlobalVariableModel playerStatList]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [Stats setObject:@1 forKey:obj];
    }];
    
    for (NSInteger i = 0; i < ability - 20; i++) {
        r = arc4random() % 20;
        NSInteger stat = [[Stats objectForKey:[[GlobalVariableModel playerStatList]objectAtIndex:r]]integerValue];
        [Stats setObject:[NSNumber numberWithInteger:stat+1] forKey:[[GlobalVariableModel playerStatList]objectAtIndex:r]];
    }
    [newPlayer addEntriesFromDictionary:Stats];
    
    
    //Profiles
    StatBiasID = arc4random() % statBiasMax + 1;
    GrowthID = arc4random() % growthMax + 1;
    DecayConstantID = arc4random() % decayKMax + 1;
    DecayID = arc4random() % decayMax + 1;
    [newPlayer setObject:[NSNumber numberWithInteger:StatBiasID] forKey:@"StatBiasID"];
    [newPlayer setObject:[NSNumber numberWithInteger:GrowthID] forKey:@"GrowthID"];
    [newPlayer setObject:[NSNumber numberWithInteger:DecayConstantID] forKey:@"DecayConstantID"];
    [newPlayer setObject:[NSNumber numberWithInteger:DecayID] forKey:@"DecayID"];
    
    //Name
    FirstName = [FirstNames objectAtIndex:arc4random() % [FirstNames count]];
    LastName = [LastNames objectAtIndex:arc4random() % [LastNames count]];
    DisplayName = LastName;
    [newPlayer setObject:FirstName forKey:@"FirstName"];
    [newPlayer setObject:LastName forKey:@"LastName"];
    [newPlayer setObject:DisplayName forKey:@"DisplayName"];

    
    
    //Consistency
    Consistency = arc4random() % 17 + arc4random() % 4 + 1;
    [newPlayer setObject:[NSNumber numberWithInteger:Consistency] forKey:@"Consistency"];
    
    //WkOfBirth
    WkOfBirth =  ((season - 20) * 50 ) + arc4random() % 100;
    [newPlayer setObject:[NSNumber numberWithInteger:WkOfBirth] forKey:@"WkOfBirth"];
    
    //Condition + Form
    Condition = 1;
    [newPlayer setObject:[NSNumber numberWithDouble:Condition] forKey:@"Condition"];
    
    Form = 1;
    [newPlayer setObject:[NSNumber numberWithDouble:Form] forKey:@"Form"];
    
    return [[[DatabaseModel alloc]init]insertDatabaseTable:@"players" withData:newPlayer];
}
@end
