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

@implementation Plan
@synthesize TrainingID;
@synthesize Coach;
@synthesize Players;
@synthesize PlanStats;
@synthesize PlayersExp;
@synthesize PlayersID;

- (id) initWithTrainingID:(NSInteger) TrainingID
{
    self = [super init];
    if (self) {
        PlanStats = [[NSMutableDictionary alloc]initWithDictionary:[[[DatabaseModel alloc]init]getResultDictionaryForTable:@"training" withKeyField:@"TrainingID" withKey:TrainingID]];
        NSInteger CoachID = [[PlanStats objectForKey:@"CoachID"]integerValue];
        Coach = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"coaches" withKeyField:@"CoachID" withKey:CoachID];
        PlayersID = [[[DatabaseModel alloc]init]getArrayFrom:@"trainingExp" withSelectField:@"PlayerID" whereKeyField:@"TrainingID" hasKey:TrainingID];

    }
    return self;
}

- (void) runTrainingPlan
{
    [PlayersID enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player* thisPlayer = [[[GameModel gameData]myTeam]getPlayerWithID:[obj integerValue]];
        [self runTrainingPlanForPlayer:thisPlayer];
    }];
}

- (void) runTrainingPlanForPlayer:(Player*) thisPlayer
{
    __block double totalStat;
    
    NSArray *groupArray = [[GlobalVariableModel playerGroupStatList] allKeys];

    NSDictionary * groupStatList = [GlobalVariableModel playerGroupStatList];

    NSMutableDictionary* changeExpList = [NSMutableDictionary dictionary];
    
    
    NSDictionary* trainingEXP = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"trainingExp" withKeyField:@"PlayerID" withKey:thisPlayer.PlayerID];

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
        
        if (statExp <= -3 || statExp >= 3) {
            [self getChangeStatStringWithGroup:obj Player:thisPlayer];
            [changeExpList setObject:@0 forKey:obj];
        } else {
            [changeExpList setObject:@(statExp) forKey:obj];
        }
        
    }];
    
    [thisPlayer updatePlayerInDatabaseStats:YES GameStat:NO Team:NO Position:NO];
    [self updateTrainingExpForPlayer:thisPlayer WithExp:changeExpList];
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
    //double coach1M;
    //double coach2M;
    double coachM;
    double growthM;
    double realisedM;
    double absoluteM;
    double biasM;
    double decayProb;
    double trainingProb;
    int expChange = 0;
    
    NSInteger age = [[GameModel gameData]weekdate] - player.WkOfBirth;
    NSInteger ageGroup = age - (age % 100);
    
    if (isMatch) {
        trainingM = 0.5;
        coachM = 1;
    } else {
        trainingM = [self getTrainingPlanMultiplerWithGroup:group];
        coachM = [self getCoachMultiplierWithCoach:Coach Group:group PlayerGroupStat:gStat];
        //coach2M = [self getCoachMultiplierWithCoach:Coach2 Group:group PlayerGroupStat:gStat];
        //coachM = MAX(coach1M,coach2M) * .6 + MIN(coach1M,coach2M) * .4;
    }
    
    potentialM = (double) (player.Potential / 200);

    growthM = [self getMultiplierWithType:@"GROWTH" ID:player.GrowthID Age:ageGroup];
    
    decayProb = [self getMultiplierWithType:@"DECAY" ID:player.DecayID Age:ageGroup] * player.Potential + [self getMultiplierWithType:@"DECAYCONSTANT" ID:player.DecayConstantID Age:ageGroup];
    
    if (tStat/player.Potential/3.60 < 0.4) decayProb = 0;
    if (gStat/player.Potential/0.72 < 0.3) decayProb = 0;
    if (tStat < 75 + .5 * player.Potential) decayProb = 0;
    
    realisedM = [self getRealisedMultiplierWithTotalStat:tStat Potential:player.Potential];
    absoluteM = [self getAbsoluteMultiplierWithTotalStat:tStat];
    biasM = [self getBiasMultiplierWithStatBiasID:player.StatBiasID StatGroup:group];
    
    trainingProb = MIN(potentialM * realisedM * growthM * biasM * coachM * absoluteM * trainingM,0.95);
    
    if (arc4random()*10000 < trainingProb*10000) expChange++;
    if (arc4random()*10000 < decayProb*10000) expChange--;
    
    if ((expChange >0 &&
         (gStat > (double) player.Potential *.8 ||
          tStat > (double) player.Potential * 3.6))) {
             expChange = 0;
         }
    return expChange;
}

- (void) getChangeStatStringWithGroup:(NSString*) group Player:(Player*) player{
    NSMutableArray* statArray = [[NSMutableArray alloc]initWithArray:[[[GlobalVariableModel playerGroupStatList] objectForKey:group]allKeys]];
    
    NSInteger stat;
    NSString* changeStat = @"";
    while ([statArray count] > 0) {
        NSInteger r = arc4random() % ([statArray count]-1);
        changeStat = [statArray objectAtIndex:r];
        stat = [[player.Stats objectForKey:changeStat]integerValue];
        if (stat < 20 && stat > 1) {
            stat = [[player.Stats objectForKey:changeStat]integerValue];
            [player.Stats setObject:[NSNumber numberWithInteger:stat] forKey:changeStat];
            break;
        } else {
            [statArray removeObjectAtIndex:r];
        }
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

-(double) getBiasMultiplierWithStatBiasID:(NSInteger) StatBiasID StatGroup: (NSString*) group {
    
    return [[[[[DatabaseModel alloc]init]getResultDictionaryForTable:@"statBias" withKeyField:@"STATBIASID" withKey:StatBiasID]objectForKey:group]doubleValue];
}

- (double) getCoachMultiplierWithCoachStat:(NSInteger)coach PlayerGroupStat:(NSInteger)gStat {
    return MAX(MIN((0.15 * coach + -0.25 * gStat / 4 + 2.2) * (0.7 + coach * 0.015),1),0) * (0.7 + coach * 0.015);
}

- (double) getCoachMultiplierWithCoach:(NSDictionary*)coach Group:(NSString*) group PlayerGroupStat:(NSInteger)gStat {
    return MAX(
               MIN(
                   (0.15 * [[coach objectForKey:group]doubleValue] + -0.25 * gStat / 4 + 2.2) * (0.7 + [[coach objectForKey:group]doubleValue] * 0.015) //Min1
                   ,1) //Min2 / Max1
               ,0) * //Max2
    (0.7 + [[coach objectForKey:group]doubleValue] * 0.015) *
    [[coach objectForKey:@"MOTIVATION"]doubleValue];
}


- (double) getTrainingPlanMultiplerWithGroup:(NSString*) group {
    double trainingGroupM = [[PlanStats objectForKey:group]doubleValue] * .2 + 1;
    double trainingIntensityM = [[PlanStats objectForKey:group]doubleValue] * .2 + .5;
    return trainingGroupM * trainingIntensityM;
}


- (double) getMultiplierWithType:(NSString*) type ID: (NSInteger) ProfileID Age:(NSInteger) age {
    // types available GROWTH DECAY DECAYCONSTANT
    //[db open];
    NSDictionary* record = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"trainingProfile" withDictionary:[[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:ProfileID],@"PROFILEID",[NSNumber numberWithInteger:age],@"AGE", nil]];
    return [[record objectForKey:type]doubleValue];
}


- (double) getAbsoluteMultiplierWithTotalStat: (int) stat {
    return MAX(MIN(1.2 - 0.55 * (double)stat/360 + 0.01 * ((double)stat/360) * ((double)stat/360),1),0.7);
}

- (double) getRealisedMultiplierWithTotalStat: (int) stat Potential:(int) potential{
    
    return MAX(MIN(-.25 + 4.1 * (double)stat/potential - 3.5 * ((double)stat/potential) * ((double)stat/potential),1),0.6);
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
