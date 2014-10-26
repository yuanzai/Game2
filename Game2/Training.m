//
//  Training.m
//  MatchEngine
//
//  Created by Junyuan Lau on 30/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Training.h"
#import "DatabaseModel.h"
#import "GameModel.h"
#import "Team.h"
#import "Player.h"
#import "SinglePlayerData.h"

@implementation Plan {
    NSArray *groupArray;
    NSDictionary * groupStatList;
    NSDictionary * statBiasTable;
    NSInteger season;
    NSTimeInterval timeInterval;
    NSDictionary* ageProfiles;
    NSInteger statExpMax;
    NSInteger expReps;

}

@synthesize TrainingID;
@synthesize Coach;
@synthesize Players;
@synthesize PlanStats;
@synthesize PlayersExp;
@synthesize PlayersID;

- (id) initWithDefault
{
    self = [super init];
    if (self) {
        groupArray = [[GlobalVariableModel playerGroupStatList] allKeys];
        groupStatList = [GlobalVariableModel  playerGroupStatList];
        statBiasTable = [GlobalVariableModel statBiasTable];
        season = [[[GameModel myGame]myData]season];
        ageProfiles = [GlobalVariableModel ageProfile];
        statExpMax = 3;
        expReps = 1;
    }
    return self;
}

- (id) initWithPotential:(NSInteger) potential Age:(NSInteger) age
{
    self = [self initWithDefault];
    if (self) {
        PlanStats = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"0",@"DRILLS",
                     @"0",@"SHOOTING",
                     @"0",@"PHYSICAL",
                     @"0",@"TACTICS",
                     @"0",@"SKILLS",
                     @"1",@"INTENSITY", nil];
        
        NSMutableDictionary* setCoach = [NSMutableDictionary dictionary];
        [setCoach setValue:@"6" forKeyPath:@"DRILLS"];
        [setCoach setValue:@"6" forKeyPath:@"SHOOTING"];
        [setCoach setValue:@"6" forKeyPath:@"PHYSICAL"];
        [setCoach setValue:@"6" forKeyPath:@"TACTICS"];
        [setCoach setValue:@"6" forKeyPath:@"SKILLS"];
        [setCoach setValue:@"6" forKeyPath:@"MOTIVATION"];
        
        NSInteger r = (potential / 16 + (arc4random() % 5) + MIN(age/3,3)) * 6;
        
        for (NSInteger i = 0; i < r; i++) {
            NSInteger k = arc4random() % 6;
            NSString* key = [[setCoach allKeys]objectAtIndex:k];
            NSInteger stat = [[setCoach objectForKey:key]integerValue];
            [setCoach setObject:[NSNumber numberWithInteger:stat+1] forKey:key];
        }
        Coach = setCoach;
    }
    return self;

}

- (id) initWithTrainingID:(NSInteger) thisTrainingID
{
    self = [self initWithDefault];
    if (self) {
        PlanStats = [[NSMutableDictionary alloc]initWithDictionary:[[[DatabaseModel alloc]init]getResultDictionaryForTable:@"training" withKeyField:@"TrainingID" withKey:thisTrainingID]];
        NSInteger CoachID = [[PlanStats objectForKey:@"CoachID"]integerValue];
        Coach = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"coaches" withKeyField:@"CoachID" withKey:CoachID];
        PlayersID = [[[DatabaseModel alloc]init]getArrayFrom:@"trainingExp" withSelectField:@"PlayerID" whereKeyField:@"TrainingID" hasKey:[NSNumber numberWithInteger:thisTrainingID]];

    }
    return self;
}

- (void) runTrainingPlan
{
    [PlayersID enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player* thisPlayer = [[[GameModel gameData]myTeam]getPlayerWithID:[obj integerValue]];
        NSMutableDictionary* trainingEXP =[[NSMutableDictionary alloc] initWithDictionary:[[[DatabaseModel alloc]init]getResultDictionaryForTable:@"trainingExp" withKeyField:@"PlayerID" withKey:thisPlayer.PlayerID]];
        
        [self runTrainingPlanForPlayer:thisPlayer TrainingExp:trainingEXP];
        [thisPlayer updatePlayerInDatabaseStats:YES GameStat:NO Team:NO Position:NO Valuation:NO];
        [self updateTrainingExpForPlayer:thisPlayer WithExp:trainingEXP];
    }];
}

- (void) runTrainingPlanForPlayer:(Player *)thisPlayer Times:(NSInteger) times ExpReps : (NSInteger) reps Season:(NSInteger) setSeason
{
    season = setSeason;
    expReps = reps;
    NSMutableDictionary* trainingEXP = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        @0,@"DRILLS",
                                        @0,@"SHOOTING",
                                        @0,@"PHYSICAL",
                                        @0,@"TACTICS",
                                        @0,@"SKILLS", nil];
    for (NSInteger i = 0 ; i < times; i++) {
        [self runTrainingPlanForPlayer:thisPlayer TrainingExp:trainingEXP];
    }
}

- (void) runTrainingPlanForPlayer:(Player*) thisPlayer TrainingExp:(NSMutableDictionary*) trainingEXP
{
    __block double totalStat;
    [thisPlayer.Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        totalStat += [obj doubleValue];
    }];
    [groupArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block double gStat = 0.0;

        NSInteger statExp = [[trainingEXP objectForKey:obj]integerValue];
        NSArray* thisArray = (NSArray*)[groupStatList objectForKey:obj];

        [thisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            gStat += [[thisPlayer.Stats objectForKey:obj]doubleValue];
        }];

        statExp += [self updateOneGroup:obj GroupStat:gStat TotalStat:totalStat StatExp:statExp Player:thisPlayer isMatch:NO];
        
        //update training exp
        //update stat
        
        if (statExp / statExpMax == 0) {
            [trainingEXP setObject:@(statExp) forKey:obj];
            
        } else if (statExp > 0) {
            
            for (int i = 0; i < statExp/statExpMax; i ++) {
                if (gStat < (double) thisPlayer.Potential *.8 ||
                    totalStat < (double) thisPlayer.Potential * 2.6 + 100) {
                    [self getChangeStatStringWithGroup:obj Player:thisPlayer upChange:YES];
                }
            }
            [trainingEXP setObject:@(statExp % statExpMax) forKey:obj];
        } else if (statExp < 0) {
            
            for (int i = 0; i < -statExp/statExpMax; i ++) {
                if (gStat > 15 + (double) thisPlayer.Potential * .2||
                    totalStat > (double) thisPlayer.Potential * .6 + 80) {
                    [self getChangeStatStringWithGroup:obj Player:thisPlayer upChange:NO];
                }
            }
            [trainingEXP setObject:@(statExpMax - statExp % statExpMax) forKey:obj];
        }
    }];
}



- (void) updateTrainingExpForPlayer:(Player*) player WithExp:(NSDictionary*) data
{
    [[[DatabaseModel alloc]init]updateDatabaseTable:@"trainingExp" withKeyField:@"PlayerID" withKey:player.PlayerID withDictionary:data];
}

- (int) updateOneGroup:(NSString*) group
             GroupStat:(NSInteger) gStat
             TotalStat:(NSInteger) tStat
               StatExp:(NSInteger) statExp
                Player:(Player*) player
               isMatch:(BOOL) isMatch
{
    
    double potentialM;
    double trainingM;
    double coachM;
    double growthM;
    double realisedM;
    double absoluteM;
    double biasM;
    double decayProb;
    double trainingProb;
    int expChange = 0;

    NSInteger age = season - player.BirthYear;
    
    if (isMatch) {
        trainingM = 0.5;
        coachM = 1;
    } else {
        trainingM = [self getTrainingPlanMultiplerWithGroup:group];
        coachM = [self getCoachMultiplierWithCoach:Coach Group:group PlayerGroupStat:gStat];
    }

    potentialM = ((double) player.Potential + 15) / 200;

    growthM = [self getMultiplierWithType:@"GROWTH" ID:player.GrowthID Age:age];

    decayProb = [self getMultiplierWithType:@"DECAY" ID:player.DecayID Age:age] * (double) player.Potential + [self getMultiplierWithType:@"DECAYCONSTANT" ID:player.DecayConstantID Age:age];

    
    
    if ((double)tStat/(double)player.Potential/3.60 < 0.4)
        decayProb = 0;
    
    if ((double)gStat/(double)player.Potential/0.72 < 0.3)
        decayProb = 0;
    
    if ((double)tStat < 75 + .5 * (double)player.Potential)
        decayProb = 0;
    
    realisedM = [self getRealisedMultiplierWithTotalStat:tStat Potential:player.Potential];
    absoluteM = [self getAbsoluteMultiplierWithTotalStat:tStat];
    biasM = [[[statBiasTable objectForKey:[NSString stringWithFormat:@"%i", player.StatBiasID]]objectForKey:group] doubleValue] + 1;

//    NSLog(@"%f,%f,%f,%f,%f,%f,%f",potentialM,realisedM,growthM,biasM,coachM,absoluteM,trainingM);
    trainingProb = MIN(potentialM * realisedM * growthM * biasM * coachM * absoluteM * trainingM,0.95);

    for (NSInteger i = 0; i < expReps; i ++) {
        if (arc4random()*10000 < trainingProb*10000) expChange++;
        if (arc4random()*10000 < decayProb*10000) expChange--;
    }

    return expChange;
}

- (void) getChangeStatStringWithGroup:(NSString*) group Player:(Player*) player upChange:(BOOL) isUp{
    NSArray* statArray = [[groupStatList objectForKey:group]allKeys];
    NSMutableArray* validStats = [NSMutableArray array];
    
    
    [statArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (isUp) {
            if ([[player.Stats objectForKey:obj]integerValue] < 20)
                [validStats addObject:obj];
        } else {
            if ([[player.Stats objectForKey:obj]integerValue] > 1)
                [validStats addObject:obj];
        }
    }];
    
    NSString* changeStat = [validStats objectAtIndex:arc4random() % [validStats count]];
    
    NSInteger stat = [[player.Stats objectForKey:changeStat]integerValue];
    if (isUp) {
        [player.Stats setObject:[NSNumber numberWithInteger:stat + 1] forKey:changeStat];
    } else {
        [player.Stats setObject:[NSNumber numberWithInteger:stat - 1] forKey:changeStat];
    }
}

- (void) addPlayerToTrainingPlan:(NSInteger) PlayerID
{
 //TODO: addPlayerToTrainingPlan
}

- (void) removePlayerFromTrainingPlan:(NSInteger) PlayerID
{
 //TODO: removePlayerFromTrainingPlan    
}

- (BOOL) updateTrainingPlanToDatabase
{
    return [[[DatabaseModel alloc]init]updateDatabaseTable:@"training" withKeyField:@"TrainingID" withKey:TrainingID withDictionary:PlanStats];
}

- (BOOL) updatePlanStats:(NSString*)stat Value:(NSInteger) value
{
    if ([[PlanStats objectForKey:stat]integerValue] == value)
        return NO;
    [PlanStats setObject:[NSNumber numberWithInteger:value] forKey:stat];
    return [self updateTrainingPlanToDatabase];
}

- (double) getCoachMultiplierWithCoach:(NSDictionary*)coach Group:(NSString*) group PlayerGroupStat:(NSInteger)gStat {
    return MAX(
               MIN(
                   (0.15 * [[coach objectForKey:group]doubleValue] + -0.25 * gStat / 4 + 2.2) *
                   (0.7 + [[coach objectForKey:group]doubleValue] * 0.015) //Min1
                   ,1) //Min2 / Max1
               ,0) * //Max2
    (0.7 + [[coach objectForKey:group]doubleValue] * 0.015) *
    (0.9 + [[coach objectForKey:@"MOTIVATION"]doubleValue]/20);
}


- (double) getTrainingPlanMultiplerWithGroup:(NSString*) group {
    double trainingGroupM = [[PlanStats objectForKey:group]doubleValue] * .2 + 1;
    double trainingIntensityM = [[PlanStats objectForKey:group]doubleValue] * .2 + .5;
    return trainingGroupM * trainingIntensityM;
}


- (double) getMultiplierWithType:(NSString*) type ID: (NSInteger) ProfileID Age:(NSInteger) age {

    NSDictionary* profile = [ageProfiles objectForKey:[NSString stringWithFormat:@"%i", age]];
    NSDictionary* record = [profile objectForKey:[NSString stringWithFormat:@"%i", ProfileID]];
    
    return [[record objectForKey:type]doubleValue];
}


- (double) getAbsoluteMultiplierWithTotalStat: (int) stat {
    return MAX(MIN(1.2 - 0.55 * (double)stat/360 + 0.01 * ((double)stat/360) * ((double)stat/360),1),0.7);
}

- (double) getRealisedMultiplierWithTotalStat: (int) stat Potential:(int) potential{
    
    return MAX(
               MIN(-.25 + 4.1 * (double)stat/potential - 3.5 * ((double)stat/potential) * ((double)stat/potential),1)
               ,0.6);
}

@end

@implementation GKTraining

- (void) trainGK:(Player*) gk
{
    
}

@end

@implementation Training
@synthesize Plans;

- (id) init {
    if (!(self = [super init]))
		return nil;
    Plans = [NSMutableArray array];
    for (NSInteger i = 0; i<4; i++) {
        Plan* plan = [[Plan alloc]initWithTrainingID:i];
        [Plans addObject:plan];
    };
    return self;
}

- (void) runAllPlans
{
    [Plans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Plan*) obj runTrainingPlan];
    }];
}


@end
