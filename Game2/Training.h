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

@interface Coach : NSObject
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


@interface Plan: NSObject <NSCoding>

@property NSInteger TrainingID;
@property NSMutableDictionary* PlayersExp;
@property Coach* thisCoach;
@property NSMutableSet* PlayerList;
@property NSMutableDictionary* PlanStats;

- (id) initWithTrainingID:(NSInteger) thisTrainingID;
- (id) initWithPotential:(NSInteger) potential Age:(NSInteger) age;
- (id) initWithCoach:(Coach*) newCoach PlayerList:(NSArray*) playerArray StatsGroup:(NSArray*) statGroupArray
;

- (void) runTrainingPlan;

- (void) runTrainingPlanForPlayer:(Player *)thisPlayer Times:(NSInteger) times ExpReps : (NSInteger) reps Season:(NSInteger) setSeason;

- (void) runTrainingPlanForPlayer:(Player*) thisPlayer TrainingExp:(NSMutableDictionary*) trainingEXP;

- (void) trainGK:(Player*) gk Season:(NSInteger) setSeason;

- (void) addPlayerToTrainingPlan:(Player*) thisPlayer;

- (void) removePlayerFromTrainingPlans:(Player*) thisPlayer;

- (BOOL) updateTrainingPlanToDatabase;
- (BOOL) updatePlanStats:(NSString*)stat Value:(NSInteger) value;
+ (double) addToRuntime:(int)no amt:(double) amt;
@end

@interface Training : NSObject
@property NSMutableArray* Plans;

- (void) runAllPlans;
- (NSArray*) getUnassignedPlayers;


@end
