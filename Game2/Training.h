//
//  Training.h
//  MatchEngine
//
//  Created by Junyuan Lau on 30/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@class Player;
@class GameModel;
@interface Coach : NSObject <NSCoding>
@property NSString* COACHNAME;
@property NSInteger COACHDRILLS;
@property NSInteger COACHSHOOTING;
@property NSInteger COACHPHYSICAL;
@property NSInteger COACHTACTICS;
@property NSInteger COACHSKILLS;
@property NSInteger MOTIVATION;
@property NSInteger JUDGEMENT;
@property NSArray* valueArray;
@end

@interface PlayerExp : NSObject <NSCoding>
@property NSInteger DRILLS;
@property NSInteger SHOOTING;
@property NSInteger PHYSICAL;
@property NSInteger TACTICS;
@property NSInteger SKILLS;
@end


@interface Plan: NSObject <NSCoding>

@property Coach* thisCoach;
@property NSMutableDictionary* PlayersExp;
@property NSMutableDictionary* PlanStats;

@property NSMutableSet* PlayerList;
@property NSMutableSet* PlayerIDList;

@property BOOL isActive;
@property GameModel* myGame;
@property NSInteger season;

// reference variables
@property NSArray *groupArray;
@property NSDictionary * groupStatList;
@property NSDictionary * statBiasTable;
@property NSDictionary * trainingProfile;
@property NSArray* ageProfiles;

@property NSInteger statExpMax;
@property NSInteger expReps;


// info variables
@property NSInteger upStatSum;
@property NSInteger downStatSum;
@property NSInteger upExpSum;
@property NSInteger downExpSum;



- (id) initWithPotential:(NSInteger) potential Age:(NSInteger) age;
- (id) initWithCoach:(Coach*) newCoach PlayerList:(NSArray*) playerArray StatsGroup:(NSArray*) statGroupArray
;
- (void) setPlayerList;
- (void) setVariables;

- (void) runTrainingPlan;

- (void) runTrainingPlanForPlayer:(Player *)thisPlayer Times:(NSInteger) times ExpReps : (NSInteger) reps Season:(NSInteger) setSeason;

- (void) runTrainingPlanForPlayer:(Player*) thisPlayer TrainingExp:(PlayerExp*) trainingEXP;

- (void) trainGK:(Player*) gk Season:(NSInteger) setSeason;

- (void) addPlayerToTrainingPlan:(Player*) thisPlayer;

- (void) removePlayerFromTrainingPlans:(Player*) thisPlayer;

- (BOOL) updatePlanStats:(NSString*)stat Value:(NSInteger) value;
+ (double) addToRuntime:(int)no amt:(double) amt;
@end

@interface Training : NSObject <NSCoding>
@property NSMutableArray* Plans;
@property NSMutableDictionary* playerExps;
@property GameModel* myGame;
@property NSInteger lastRun;

- (void) runAllPlans;
- (NSArray*) getUnassignedPlayers;
- (NSInteger) getUpStats;
- (NSInteger) getDownStats;
- (NSInteger)getUpExp;
- (NSInteger)getDownExp;

@end

