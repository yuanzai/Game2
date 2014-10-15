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
@interface Plan: NSObject

@property NSInteger TrainingID;
@property NSArray* PlayersID;
@property NSArray* PlayersExp;
@property NSDictionary* Coach;
@property NSArray* Players;

@property NSMutableDictionary* PlanStats;

- (id) initWithTrainingID:(NSInteger) thisTrainingID;
- (void) runTrainingPlan;
- (void) runTrainingPlanForPlayer:(Player*) thisPlayer;
- (void) addPlayerToTrainingPlan:(NSInteger) PlayerID;
- (void) removePlayerFromTrainingPlan:(NSInteger) PlayerID;

- (BOOL) updateTrainingPlanToDatabase;
- (BOOL) updatePlanStats:(NSString*)stat Value:(NSInteger) value;

@end

@interface Training : NSObject
{
    NSMutableArray* Plans;
}
@property NSArray* Plans;

- (void) runAllPlans;

@end
