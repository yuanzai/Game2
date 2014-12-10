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

@implementation Coach
{
    GameModel* myGame;
}
@synthesize valueArray;
@synthesize COACHDRILLS, COACHPHYSICAL,COACHSHOOTING,COACHSKILLS,COACHTACTICS,COACHNAME,JUDGEMENT,MOTIVATION;

- (id) initWithCoachID: (NSInteger) thisCoachID {
    self = [super init];
    if (self) {
        myGame = [GameModel myGame];
        valueArray = [NSArray arrayWithObjects:@"COACHDRILLS",
                      @"COACHPHYSICAL",
                      @"COACHSHOOTING",
                      @"COACHSKILLS",
                      @"COACHTACTICS",
                      @"COACHNAME",
                      @"JUDGEMENT",
                      @"MOTIVATION", nil];
        NSDictionary* result = [[GameModel myDB]getResultDictionaryForTable:@"training" withKeyField:@"TRAININGID" withKey:thisCoachID];
        NSLog(@"Coach %@",result);
        [valueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self setValue:[result objectForKey:obj] forKey:obj];
        }];
    }
    return self;
}

@end

@implementation Plan {
    NSArray *groupArray;
    NSDictionary * groupStatList;
    NSDictionary * statBiasTable;
    NSInteger season;
    NSTimeInterval timeInterval;
    NSArray* ageProfiles;
    NSInteger statExpMax;
    NSInteger expReps;
    NSMutableSet* PlayerIDList;
}

@synthesize TrainingID;
@synthesize thisCoach;
@synthesize PlayerList;
@synthesize PlanStats;
@synthesize PlayersExp;

static double runtime1 =0.0;
static double runtime2 =0.0;
static double runtime3 =0.0;

- (id) initWithDefault
{
    self = [super init];
    if (self) {
        groupArray = [[GlobalVariableModel playerGroupStatList] allKeys];
        groupStatList = [GlobalVariableModel  playerGroupStatList];
        statBiasTable = [[GameModel myGlobalVariableModel] statBiasTable];
        season = [[[GameModel myGame]myData]season];
        ageProfiles = [[GameModel myGlobalVariableModel] ageProfile];
        statExpMax = 3;
        expReps = 1;
        PlayerList = [NSMutableSet set];
        PlayerIDList = [NSMutableSet set];
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
        
        thisCoach = [Coach new];
        [thisCoach setValue:@(6) forKeyPath:@"COACHDRILLS"];
        [thisCoach setValue:@(6) forKeyPath:@"COACHSHOOTING"];
        [thisCoach setValue:@(6) forKeyPath:@"COACHPHYSICAL"];
        [thisCoach setValue:@(6) forKeyPath:@"COACHTACTICS"];
        [thisCoach setValue:@(6) forKeyPath:@"COACHSKILLS"];
        [thisCoach setValue:@(6) forKeyPath:@"MOTIVATION"];
        [thisCoach setValue:[NSArray arrayWithObjects:@"COACHDRILLS",@"COACHSHOOTING",@"COACHPHYSICAL",@"COACHTACTICS",@"COACHSKILLS",@"MOTIVATION", nil] forKey:@"valueArray"];
        
        NSInteger r = (potential / 16 + (arc4random() % 5) + MIN(age/3,3)) * 6;
        
        for (NSInteger i = 0; i < r; i++) {
            NSInteger k = arc4random() % 6;
            NSString* key = [thisCoach.valueArray objectAtIndex:k];
            NSInteger stat = [[thisCoach valueForKey:key]integerValue];
            [thisCoach setValue:[NSNumber numberWithInteger:stat+1] forKey:key];
        }
    }
    return self;
}

- (id) initWithTrainingID:(NSInteger) thisTrainingID
{
    self = [self initWithDefault];
    if (self) {
        TrainingID = thisTrainingID;
        PlanStats = [[NSMutableDictionary alloc]initWithDictionary:[[GameModel myDB]getResultDictionaryForTable:@"training" withKeyField:@"TRAININGID" withKey:thisTrainingID]];

        thisCoach = [[Coach alloc]initWithCoachID:TrainingID];
        
        //Populate Player ID List
        PlayerIDList = [NSMutableSet setWithArray:[[GameModel myDB]getArrayFrom:@"trainingExp" withSelectField:@"PLAYERID" whereKeyField:@"TRAININGID" hasKey:[NSNumber numberWithInteger:thisTrainingID]]];

        //Populate Player List
        [PlayerIDList enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            Player* thisPlayer = [[[GameModel myGlobalVariableModel]playerList]objectForKey:[NSString stringWithFormat:@"%@",obj]];
            if (thisPlayer.TeamID != 0) {
                [self removePlayerFromTrainingPlans:thisPlayer];
            } else {
                [PlayerList addObject:thisPlayer];
                [PlayersExp setObject:thisPlayer forKey:[obj stringValue]];
            }
        }];
        
        //Populate Player Exp Dictionary
        NSArray* expList = [[GameModel myDB] getArrayFrom:@"trainingExp" whereKeyField:@"TRAININGID" hasKey:[NSNumber numberWithInteger:thisTrainingID] sortFieldAsc:@""];
        [expList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            [PlayersExp setObject:[NSMutableDictionary dictionaryWithDictionary:obj] forKey:[@([[obj objectForKey:@"PLAYERID"]integerValue]) stringValue]];
        }];
    }
    return self;
}

- (id) initWithCoach:(Coach*) newCoach PlayerList:(NSArray*) playerArray StatsGroup:(NSArray*) statGroupArray
{
    self = [self initWithDefault];
    if (self) {
        thisCoach = newCoach;
        PlanStats = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"0",@"DRILLS",
                     @"0",@"SHOOTING",
                     @"0",@"PHYSICAL",
                     @"0",@"TACTICS",
                     @"0",@"SKILLS",
                     @"1",@"INTENSITY", nil];
        if (groupArray)
            groupArray = statGroupArray;
        PlayerList = [NSMutableSet setWithArray:playerArray];
    } ; return self;
}

- (void) runTrainingPlan
{
    [PlayerList enumerateObjectsUsingBlock:^(Player* p, BOOL *stop) {
        NSMutableDictionary* trainingEXP = [PlayersExp objectForKey:[@(p.PlayerID) stringValue]];
        [p updatePlayerInDatabaseStats:YES GameStat:NO Team:NO Position:NO Valuation:NO];
        [self updateTrainingExpForPlayer:p WithExp:trainingEXP];
    }];
}

- (void) runTrainingPlanForPlayer:(Player *)thisPlayer Times:(NSInteger) times ExpReps : (NSInteger) reps Season:(NSInteger) setSeason
{
    // AI Simulation
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
    [[GameModel myDB]updateDatabaseTable:@"trainingExp" withKeyField:@"PLAYERID" withKey:player.PlayerID withDictionary:data];
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
    NSDate * date = [NSDate date];

    NSInteger age = season - player.BirthYear;
    
    if (isMatch) {
        trainingM = 0.5;
        coachM = 1;
    } else {
        trainingM = [self getTrainingPlanMultiplerWithGroup:group];
        coachM = [self getCoachMultiplierGroup:group PlayerGroupStat:gStat];
    }

    potentialM = ((double) player.Potential + 15) / 200;

    growthM = [self getMultiplierWithType:@"GROWTH" ID:player.GrowthID Age:age];
    double decay = [self getMultiplierWithType:@"DECAY" ID:player.DecayID Age:age];

    [Plan addToRuntime:1 amt:-[date timeIntervalSinceNow]];
    date = [NSDate date];
    
    double decayK = [self getMultiplierWithType:@"DECAYCONSTANT" ID:player.DecayConstantID Age:age];
    [Plan addToRuntime:2 amt:-[date timeIntervalSinceNow]];

    decayProb = decay * (double) player.Potential + decayK;


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
    [Plan addToRuntime:3 amt:-[date timeIntervalSinceNow]];

    return expChange;
}

- (void) trainGK:(Player*) gk Season:(NSInteger) setSeason
{
    if (!gk.isGoalKeeper) {
        season = setSeason;

        __block double sumStat = 0.0;
        [gk.Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            sumStat += [obj doubleValue];
        }];
        NSInteger age = season - gk.BirthYear;
        
        double decayK = [self getMultiplierWithType:@"DECAYCONSTANT" ID:gk.DecayConstantID Age:age];
        
        double decaySlope = [self getMultiplierWithType:@"DECAY" ID:gk.DecayID Age:age];
        
        double trainingProb = MIN(0.2 + (220 - (sumStat*0.18)/25),0.95) - (decayK+(double) gk.Potential *decaySlope/100);
        
        BOOL upStat = YES;
        if (trainingProb < 0 )
            upStat = NO;
        
        NSMutableArray* validStats = [NSMutableArray array];
        
        [[GlobalVariableModel gkStatList] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (upStat) {
                if ([[gk.Stats objectForKey:obj]integerValue] < 20)
                    [validStats addObject:obj];
            } else {
                if ([[gk.Stats objectForKey:obj]integerValue] > 1)
                    [validStats addObject:obj];
            }
        }];

        
        if (arc4random()*10000 < abs(trainingProb)*10000) {
            NSInteger r = arc4random() % [validStats count];
            NSString* statString =[validStats objectAtIndex:r];
            NSInteger stat = [[gk.Stats objectForKey:statString]integerValue];
            if (upStat) {
                [gk.Stats setObject:@(stat+1) forKey:statString];
            } else {
                [gk.Stats setObject:@(stat-1) forKey:statString];
            }
        }
    }
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

- (void) addPlayerToTrainingPlan:(Player*) thisPlayer
{
    if(![[GameModel myDB]updateDatabaseTable:@"trainingExp" withKeyField:@"PLAYERID" withKey:thisPlayer.PlayerID withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@(TrainingID),@"TRAININGID", nil]])
        [NSException raise:@"update player training id" format:@"update player training id"];
    
    [PlayerList addObject:thisPlayer];
}

- (void) removePlayerFromTrainingPlans:(Player*) thisPlayer
{
    [[GameModel myDB]deleteFromTable:@"trainingExp" withData:[NSDictionary dictionaryWithObjectsAndKeys:@(thisPlayer.PlayerID),@"PLAYERID", nil]];
}

- (BOOL) updateTrainingPlanToDatabase
{    
    return [[GameModel myDB]updateDatabaseTable:@"training" withKeyField:@"TRAININGID" withKey:TrainingID withDictionary:PlanStats];
}

- (BOOL) updatePlanStats:(NSString*)stat Value:(NSInteger) value
{
    if ([[PlanStats objectForKey:stat]integerValue] == value)
        return NO;
    [PlanStats setObject:[NSNumber numberWithInteger:value] forKey:stat];
    return [self updateTrainingPlanToDatabase];
}

- (double) getCoachMultiplierGroup:(NSString*) group PlayerGroupStat:(NSInteger)gStat {
    NSString* key = [NSString stringWithFormat:@"COACH%@",group];
    return MAX(
               MIN(
                   (0.15 * [[thisCoach valueForKey:key]doubleValue] + -0.25 * gStat / 4 + 2.2) *
                   (0.7 + [[thisCoach valueForKey:key]doubleValue] * 0.015) //Min1
                   ,1) //Min2 / Max1
               ,0) * //Max2
    (0.7 + [[thisCoach valueForKey:key]doubleValue] * 0.015) *
    (0.9 + [[thisCoach valueForKey:@"MOTIVATION"]doubleValue]/20);
}


- (double) getTrainingPlanMultiplerWithGroup:(NSString*) group {
    double trainingGroupM = [[PlanStats objectForKey:group]doubleValue] * .2 + 1;
    double trainingIntensityM = [[PlanStats objectForKey:group]doubleValue] * .2 + .5;
    return trainingGroupM * trainingIntensityM;
}


- (double) getMultiplierWithType:(NSString*) type ID: (NSInteger) ProfileID Age:(NSInteger) age {
    NSDictionary* profile = [ageProfiles objectAtIndex:age];
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

+ (double) addToRuntime:(int)no amt:(double) amt
{
    if (no==1) {
        runtime1 +=amt;
        return runtime1;
    }else if (no==2) {
        runtime2 +=amt;
        return runtime2;
        
    }else if (no==3){
        runtime3 +=amt;
        return runtime3;
    }
    return 0.0;
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
    //[self syncTrainingPlansToTeam];
    return self;
}

- (void) runAllPlans
{
    [Plans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Plan*) obj runTrainingPlan];
    }];
}

- (void) syncTrainingPlansToTeam
{
    NSArray* unassigned = [self getUnassignedPlayers];
    for (Player* p in unassigned) {
        if (![[GameModel myDB]insertDatabaseTable:@"trainingExp" withData:[NSDictionary dictionaryWithObjectsAndKeys:@(p.PlayerID),@"PLAYERID",@(0),@"TRAININGID", nil]])
        
            [NSException raise:@"not inserted" format:@"not inserted"];
        
    }
}

- (NSArray*) getUnassignedPlayers
{
    NSMutableArray* playerList = [NSMutableArray arrayWithArray:[[[[GameModel myGame]myData] myTeam]PlayerList]];
    for (NSInteger i = 0; i<4; i++) {
        Plan* thisPlan = [Plans objectAtIndex:i];
        [thisPlan.PlayerList enumerateObjectsUsingBlock:^(Player* p, BOOL *stop) {
            [playerList removeObject:p];
        }];
    };
    return playerList;
}
@end
