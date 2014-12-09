//
//  Scouting.m
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Scouting.h"
#import "GameModel.h"
#import "DatabaseModel.h"
#import "Team.h"

@implementation Scouting
{
    GameModel* myGame;
}
@synthesize shortList;
@synthesize scoutArray;

- (id) init
{
    self = [super init];
    if (self){
        myGame = [GameModel myGame];
        scoutArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i ++) {
            [scoutArray addObject:[[Scout alloc]initWithScoutID:i]];
        }
        NSArray* shortListID = [[myGame myData]shortList];
        [shortListID enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [shortList addObject:[[myGame myGlobalVariableModel]getPlayerFromID:[obj integerValue]]];
        }];
    }; return self;
}

- (void) updateAllScoutsToDatabase
{
    [scoutArray enumerateObjectsUsingBlock:^(Scout* s, NSUInteger idx, BOOL *stop) {
        [s updateScoutToDatabase];
    }];
}


- (void) runAllWeeklyScouting
{
    [scoutArray enumerateObjectsUsingBlock:^(Scout* s, NSUInteger idx, BOOL *stop) {
        s.scoutResults = [s getScoutingPlayerArray];
    }];
}

@end

@implementation Scout
{
    GameModel* myGame;
}
@synthesize SCOUTID;
@synthesize NAME;
@synthesize JUDGEMENT; // judging ability + potential
@synthesize YOUTH; // judging potential in < 23yr olds
@synthesize VALUE; // abilty to price ratio
@synthesize KNOWLEDGE; // useful perks spotting
@synthesize DILIGENCE; // probabilty of more names
@synthesize SCOUTTYPE; // scout type
@synthesize SCOUTPOSITION; // scout type
@synthesize scoutResults;
@synthesize valueArray;

- (id) initWithScoutID: (NSInteger) thisScoutID {
    self = [super init];
    if (self) {
        myGame = [GameModel myGame];
        NSDictionary* result = [[GameModel myDB]getResultDictionaryForTable:@"scouts" withKeyField:@"SCOUTID" withKey:thisScoutID];
        valueArray = [result allKeys];
        [result enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self setValuesForKeysWithDictionary:result];
        }];
    }
    return self;
}

- (void) updateScoutToDatabase
{
    __block NSMutableDictionary* updateData = [NSMutableDictionary dictionary];
    [valueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [updateData setObject:[self valueForKey:obj] forKey:obj];
    }];
    [[GameModel myDB]updateDatabaseTable:@"scouts" withKeyField:@"SCOUTID" withKey:SCOUTID withDictionary:updateData];
}

- (NSArray*) getScoutingPlayerArray
{
    NSInteger success;
    switch (SCOUTTYPE) {
        case StarPlayer:
            success = 120;
            break;
        case SquadPlayer:
            success = 200;
            break;
        case Youth:
            success = 170;
            break;
        default:
            break;
    }
    if (SCOUTPOSITION != ScoutAny) {
        success /= 2;
    }
    success = (NSInteger)((double) success * (1 + (double)DILIGENCE * 0.03));
    
    if (arc4random() % 1000 > success)
        return nil;
    
    ScoutPosition pos;
    if (SCOUTPOSITION == ScoutAny) {
        NSInteger r = arc4random() % 100;
        if (r < 15) {
            pos = ScoutGoalkeeper;
        } else if (r < 45) {
            pos = ScoutDef;
        } else if (r < 75) {
            pos = ScoutMid;
        } else {
            pos = ScoutAtt;
        }
    }
    
    double valueLimit = 0.0;
    NSInteger ageLimit = [[myGame myData]season] - 42;
    NSInteger finalCut = 27 - JUDGEMENT;
    NSInteger randomCut = finalCut * 2;
    NSInteger firstCut = finalCut * 3;
    NSInteger potentialCut = YOUTH / 2;
    
    
    NSArray* players = [myGame.myData.myTeam getAllPlayersSortByValuation];
    double TopValue = ((Player*) players[0]).Valuation;
    double Top4Value = 0.0;
    for (NSInteger i = 0; i < 4; i ++) {
        Top4Value+= ((Player*) players[i]).Valuation;
    }
    
    if (SCOUTTYPE == StarPlayer) {
        valueLimit = MAX(Top4Value * 2,TopValue * 1.5);
        finalCut = 25 - JUDGEMENT;
        randomCut = finalCut * 1.5;
        firstCut = finalCut * 2;
        potentialCut = 0;
        
    } else if (SCOUTTYPE == SquadPlayer) {
        valueLimit = MAX(Top4Value * 1.65,TopValue * 1.25);
    } else if (SCOUTTYPE == Youth) {
        valueLimit = MAX(Top4Value * .95,TopValue * 0.85);
        ageLimit = [[myGame myData]season] - 25;
        finalCut = 50 - JUDGEMENT/2;
        randomCut = 50;
        firstCut = 200 - YOUTH - JUDGEMENT;
        potentialCut = YOUTH + JUDGEMENT/2;
        
    }
    
    NSMutableArray* resultArray = [NSMutableArray array];
    [resultArray addObject:[self scoutingResultwithFinalCut:finalCut RandomCut:randomCut FirstCut:firstCut PotentialCut:potentialCut ValueLimit:valueLimit Position:pos AgeLimit:ageLimit]];
    return nil;
}


- (Player*) scoutingResultwithFinalCut:(NSInteger) finalCut
                             RandomCut:(NSInteger) randomCut
                              FirstCut:(NSInteger) firstCut
                          PotentialCut:(NSInteger) potentialCut
                            ValueLimit:(double) valueLimit
                              Position:(ScoutPosition) pos
                              AgeLimit:(NSInteger) ageLimit
{
    NSString* positionSQL;
    switch (pos) {
        case ScoutAny:
            positionSQL = @"";
            break;
        case ScoutDef:
            positionSQL = @"DEF = 1";
            break;
        case ScoutMid:
            positionSQL = @"(DM = 1 OR MID = 1 OR AM = 1)";
            break;
        case ScoutAtt:
            positionSQL = @"SC = 1";
            break;
        case ScoutGoalkeeper:
            positionSQL = @"GK = 1";
            break;
        default:
            break;
    }
    
    NSString* firstCutSQL = [NSString stringWithFormat:@"SELECT * FROM players WHERE BIRTHYEAR > %i AND VALUATION < %f AND %@ ORDER BY ABILITY DESC LIMIT %i",ageLimit, valueLimit,positionSQL,firstCut];
    NSString* potentialCutSQL = [NSString stringWithFormat:@"SELECT * FROM (%@) ORDER BY POTENTIAL DESC LIMIT %i",firstCutSQL, potentialCut];
    NSString* randomCutSQL = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM (%@) ORDER BY POTENTIAL LIMIT %i) ORDER BY RANDOM() LIMIT %i",firstCutSQL, firstCut - potentialCut, randomCut - potentialCut];
    NSString* finalCutSQL = [NSString stringWithFormat:@"SELECT * FROM ((%@) UNION (%@)) ORDER BY ABILITY DESC LIMIT %i",potentialCutSQL,randomCutSQL,finalCut];
    NSString* finalOneSQL = [NSString stringWithFormat:@"SELECT PLAYERID FROM (%@) ORDER BY RANDOM() LIMIT 1",finalCutSQL];
    NSArray* resultArray = [[myGame myDB]getArrayFromQuery:finalOneSQL];
    return [[myGame myGlobalVariableModel]getPlayerFromID:[[resultArray[0] objectForKey:@"PLAYERID"]integerValue]];
}

@end
