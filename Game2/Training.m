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
#import "GlobalVariableModel.h"
#import "C2DArray_double.h"

@implementation Plan
@synthesize expReps, statExpMax;
@synthesize ageProfiles, statBiasTable, groupStatList, groupArray, trainingProfile;
@synthesize season;
@synthesize thisCoach;
@synthesize PlayerList;
@synthesize PlanStats;
@synthesize PlayersExp;
@synthesize PlayerIDList;
@synthesize isActive;
@synthesize myGame;
@synthesize upStatSum,downStatSum, upExpSum, downExpSum;


static double runtime1 =0.0;
static double runtime2 =0.0;
static double runtime3 =0.0;

- (id) init
{
    self = [super init];
    if (self) {
        PlanStats = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"0",@"DRILLS",
                     @"0",@"SHOOTING",
                     @"0",@"PHYSICAL",
                     @"0",@"TACTICS",
                     @"0",@"SKILLS",
                     @"1",@"INTENSITY", nil];
        PlayerIDList = [NSMutableSet set];
        PlayerList = [NSMutableSet set];
        thisCoach = nil;
        isActive = NO;
        [self setVariables];
    }; return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.PlayerIDList = [decoder decodeObjectForKey:@"PlayerIDList"];
    self.thisCoach = [decoder decodeObjectForKey:@"thisCoach"];
    self.PlanStats = [decoder decodeObjectForKey:@"PlanStats"];
    self.isActive = [decoder decodeIntegerForKey:@"isActive"];
    self.PlayerList = [NSMutableSet set];

    [self setVariables];
    [self setPlayerList];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.PlayerIDList forKey:@"PlayerIDList"];
    [encoder encodeObject:self.thisCoach forKey:@"thisCoach"];
    [encoder encodeObject:self.PlanStats forKey:@"PlanStats"];
    [encoder encodeInteger:self.isActive forKey:@"isActive"];

}

- (void) setPlayerList
{
    GlobalVariableModel* globals = [GlobalVariableModel myGlobalVariable];

    [PlayerIDList enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Player* thisPlayer = [globals.playerList objectForKey:[obj stringValue]];
        if (thisPlayer.TeamID != 0) {
            [self removePlayerFromTrainingPlans:thisPlayer];
        } else {
            [PlayerList addObject:thisPlayer];
        }
    }];
}

- (void) setVariables
{
    self.statExpMax = 3;
    self.expReps = 1;
    GlobalVariableModel* globals =[GlobalVariableModel myGlobalVariable];

    self.groupArray = [[GlobalVariableModel playerGroupStatList] allKeys];
    self.groupStatList = [GlobalVariableModel  playerGroupStatList];
    self.statBiasTable = [globals statBiasTable];
    self.ageProfiles = [globals ageProfile];
    self.trainingProfile = [globals trainingProfile];

}

- (id) initWithPotential:(NSInteger) potential Age:(NSInteger) age
{
    self = [self init];
    if (self) {
        
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

- (id) initWithCoach:(Coach*) newCoach PlayerList:(NSArray*) playerArray StatsGroup:(NSArray*) statGroupArray
{
    self = [self init];
    if (self) {
        thisCoach = newCoach;
        if (groupArray)
            groupArray = statGroupArray;
        PlayerList = [NSMutableSet setWithArray:playerArray];
    } ; return self;
}

- (void) runTrainingPlan
{
    statExpMax = 3;
    expReps = 1;
    season = myGame.myData.season;
    upStatSum = 0;
    downStatSum = 0;
    upExpSum = 0;
    downExpSum = 0;
    [PlayerList enumerateObjectsUsingBlock:^(Player* p, BOOL *stop) {
        PlayerExp* trainingEXP = [PlayersExp objectForKey:[@(p.PlayerID) stringValue]];
        [self runTrainingPlanForPlayer:p TrainingExp:trainingEXP];
        [p updatePlayerInDatabaseStats:YES GameStat:NO Team:NO Position:NO Valuation:NO];
    }];
}

- (void) runTrainingPlanForPlayer:(Player *)thisPlayer Times:(NSInteger) times ExpReps : (NSInteger) reps Season:(NSInteger) setSeason
{
    // AI Simulation

    season = setSeason;
    expReps = reps;
    PlayerExp* trainingEXP = [PlayerExp new];
    trainingEXP.DRILLS = 0;
    trainingEXP.SHOOTING = 0;
    trainingEXP.SKILLS = 0;
    trainingEXP.TACTICS = 0;
    trainingEXP.PHYSICAL = 0;
    
    for (NSInteger i = 0 ; i < times; i++) {
        [self runTrainingPlanForPlayer:thisPlayer TrainingExp:trainingEXP];
    }
}

- (void) runTrainingPlanForPlayer:(Player*) thisPlayer TrainingExp:(PlayerExp*) trainingEXP
{
    __block double totalStat;
    [thisPlayer.Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        totalStat += [obj doubleValue];
    }];
    
    [groupArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block double gStat = 0.0;
        
        NSInteger statExp = [[trainingEXP valueForKey:obj]integerValue];
        NSArray* thisArray = (NSArray*)[groupStatList objectForKey:obj];

        [thisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            gStat += [[thisPlayer.Stats objectForKey:obj]doubleValue];
        }];

        statExp += [self updateOneGroup:obj GroupStat:gStat TotalStat:totalStat StatExp:statExp Player:thisPlayer isMatch:NO];
        
        //update training exp
        //update stat
        
        if (statExp / statExpMax == 0) {
            [trainingEXP setValue:@(statExp) forKey:obj];
            
        } else if (statExp > 0) {
            
            for (int i = 0; i < statExp/statExpMax; i ++) {
                if (gStat < (double) thisPlayer.Potential *.8 ||
                    totalStat < (double) thisPlayer.Potential * 2.6 + 100) {
                    [self getChangeStatStringWithGroup:obj Player:thisPlayer upChange:YES];
                }
            }
            [trainingEXP setValue:@(statExp % statExpMax) forKey:obj];
        } else if (statExp < 0) {
            
            for (int i = 0; i < -statExp/statExpMax; i ++) {
                if (gStat > 15 + (double) thisPlayer.Potential * .2||
                    totalStat > (double) thisPlayer.Potential * .6 + 80) {
                    [self getChangeStatStringWithGroup:obj Player:thisPlayer upChange:NO];
                }
            }
            [trainingEXP setValue:@(statExpMax - statExp % statExpMax) forKey:obj];
        }
    }];
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
    
    decayProb = decay * (double) player.Potential/100 + decayK;


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
//    NSLog(@"%f", trainingProb);
    
    for (NSInteger i = 0; i < expReps; i ++) {
        if (arc4random()%10000 < trainingProb*10000)
            expChange++;
        if (arc4random()%10000 < decayProb*10000)
            expChange--;
    }
    [Plan addToRuntime:3 amt:-[date timeIntervalSinceNow]];
    if (expChange>0)
        upExpSum ++;
    if (expChange<0)
        downExpSum++;
    
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
    
    NSArray* statArray = [groupStatList objectForKey:group];
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
    
    if ([validStats count] ==0)
        return;
    
    NSString* changeStat = [validStats objectAtIndex:arc4random() % [validStats count]];
    
    NSInteger stat = [[player.Stats objectForKey:changeStat]integerValue];
    if (isUp) {
        upStatSum++;
        [player.Stats setObject:[NSNumber numberWithInteger:stat + 1] forKey:changeStat];
    } else {
        downStatSum++;
        [player.Stats setObject:[NSNumber numberWithInteger:stat - 1] forKey:changeStat];
    }
}

- (void) addPlayerToTrainingPlan:(Player*) thisPlayer
{
    [PlayerList addObject:thisPlayer];
    [PlayerIDList addObject:@(thisPlayer.PlayerID)];
}

- (void) removePlayerFromTrainingPlans:(Player*) thisPlayer
{
    [PlayerList removeObject:thisPlayer];
    [PlayerIDList removeObject:@(thisPlayer.PlayerID)];
}

- (BOOL) updatePlanStats:(NSString*)stat Value:(NSInteger) value
{
    if ([[PlanStats objectForKey:stat]integerValue] == value)
        return NO;
    [PlanStats setObject:[NSNumber numberWithInteger:value] forKey:stat];
    return YES;
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
    double result;
    
    //NSDictionary* profile = [ageProfiles objectAtIndex:age];
    //NSDictionary* record = [profile objectForKey:[NSString stringWithFormat:@"%i", ProfileID]];
    //result = [[record objectForKey:type]doubleValue];
    
    C2DArray_double* profileArray = trainingProfile[type];
    result = [profileArray valueAtRow:age Column:ProfileID];
    return result;
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
@synthesize Plans, playerExps, lastRun, myGame;

- (id) init {
    if (!(self = [super init]))
		return nil;
    playerExps = [NSMutableDictionary dictionary];
    [myGame.myData.myTeam.PlayerList enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        [playerExps setObject:[PlayerExp new] forKey:[@(p.PlayerID) stringValue]];
    }];
    
    Plans = [NSMutableArray array];
    for (NSInteger i = 0; i<4; i++) {
        Plan* newPlan = [Plan new];
        [Plans addObject:newPlan];
        newPlan.PlayersExp = self.playerExps;
    };
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.Plans = [decoder decodeObjectForKey:@"Plans"];
    self.playerExps = [decoder decodeObjectForKey:@"playerExps"];
    self.lastRun = [decoder decodeIntegerForKey:@"lastRun"];
    [self checkPlayers];
    
    [Plans enumerateObjectsUsingBlock:^(Plan* pl, NSUInteger idx, BOOL *stop) {
        pl.PlayersExp = self.playerExps;
    }];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.Plans forKey:@"Plans"];
    [encoder encodeObject:self.playerExps forKey:@"playerExps"];
    [encoder encodeInteger:self.lastRun forKey:@"lastRun"];
}

- (void) checkPlayers
{
    [myGame.myData.myTeam.PlayerList enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (![playerExps objectForKey:[@(p.PlayerID) stringValue]])
            [playerExps setObject:[PlayerExp new] forKey:@(p.PlayerID)];
    }];
    [playerExps enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[GlobalVariableModel myGlobalVariable] getPlayerFromID:[key integerValue]].TeamID != 0)
            [playerExps removeObjectForKey:key];
    }];
}

- (void) runAllPlans
{
    [Plans enumerateObjectsUsingBlock:^(Plan* pl, NSUInteger idx, BOOL *stop) {
        if (pl.isActive)
            [pl runTrainingPlan];
    }];
    lastRun = myGame.myData.weekdate;
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

-(NSInteger)getUpStats
{
    __block NSInteger sum = 0;
    [Plans enumerateObjectsUsingBlock:^(Plan* pl, NSUInteger idx, BOOL *stop) {
        if (pl.isActive)
            sum += pl.upStatSum;
    }];
    return sum;
}

-(NSInteger)getDownStats
{
    __block NSInteger sum = 0;
    [Plans enumerateObjectsUsingBlock:^(Plan* pl, NSUInteger idx, BOOL *stop) {
        if (pl.isActive)
            sum += pl.downStatSum;
    }];
    return sum;
}

-(NSInteger)getUpExp
{
    __block NSInteger sum = 0;
    [Plans enumerateObjectsUsingBlock:^(Plan* pl, NSUInteger idx, BOOL *stop) {
        if (pl.isActive)
            sum += pl.upExpSum;
    }];
    return sum;
}

-(NSInteger)getDownExp
{
    __block NSInteger sum = 0;
    [Plans enumerateObjectsUsingBlock:^(Plan* pl, NSUInteger idx, BOOL *stop) {
        if (pl.isActive)
            sum += pl.downExpSum;
    }];
    return sum;
}
@end

@implementation PlayerExp
@synthesize DRILLS,SHOOTING,SKILLS,TACTICS,PHYSICAL;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.DRILLS = [decoder decodeIntegerForKey:@"DRILLS"];
    self.SHOOTING = [decoder decodeIntegerForKey:@"SHOOTING"];
    self.SKILLS = [decoder decodeIntegerForKey:@"SKILLS"];
    self.TACTICS = [decoder decodeIntegerForKey:@"TACTICS"];
    self.PHYSICAL = [decoder decodeIntegerForKey:@"PHYSICAL"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.DRILLS forKey:@"DRILLS"];
    [encoder encodeInteger:self.SHOOTING forKey:@"SHOOTING"];
    [encoder encodeInteger:self.SKILLS forKey:@"SKILLS"];
    [encoder encodeInteger:self.TACTICS forKey:@"TACTICS"];
    [encoder encodeInteger:self.PHYSICAL forKey:@"PHYSICAL"];
}

@end

@implementation Coach
@synthesize valueArray;
@synthesize COACHDRILLS, COACHPHYSICAL,COACHSHOOTING,COACHSKILLS,COACHTACTICS,COACHNAME,JUDGEMENT,MOTIVATION;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.COACHDRILLS = [decoder decodeIntegerForKey:@"COACHDRILLS"];
    self.COACHPHYSICAL = [decoder decodeIntegerForKey:@"COACHPHYSICAL"];
    self.COACHSHOOTING = [decoder decodeIntegerForKey:@"COACHSHOOTING"];
    self.COACHSKILLS = [decoder decodeIntegerForKey:@"COACHSKILLS"];
    self.COACHTACTICS = [decoder decodeIntegerForKey:@"COACHTACTICS"];
    self.JUDGEMENT = [decoder decodeIntegerForKey:@"JUDGEMENT"];
    self.MOTIVATION = [decoder decodeIntegerForKey:@"MOTIVATION"];
    self.COACHNAME = [decoder decodeObjectForKey:@"COACHNAME"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.COACHDRILLS forKey:@"COACHDRILLS"];
    [encoder encodeInteger:self.COACHPHYSICAL forKey:@"COACHPHYSICAL"];
    [encoder encodeInteger:self.COACHSHOOTING forKey:@"COACHSHOOTING"];
    [encoder encodeInteger:self.COACHSKILLS forKey:@"COACHSKILLS"];
    [encoder encodeInteger:self.COACHTACTICS forKey:@"COACHTACTICS"];
    [encoder encodeInteger:self.JUDGEMENT forKey:@"JUDGEMENT"];
    [encoder encodeInteger:self.MOTIVATION forKey:@"MOTIVATION"];
    [encoder encodeObject:self.COACHNAME forKey:@"COACHNAME"];
}
@end
