//
//  Player.h
//  MatchEngine
//
//  Created by Junyuan Lau on 15/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Player : NSObject
{
    NSInteger PlayerID;
    NSInteger TeamID;
    NSString* DisplayName;
    NSString* LastName;
    NSString* FirstName;
    NSMutableDictionary* Stats;
    
    NSInteger Consistency;
    NSInteger Potential;
    NSInteger Form;
    double Condition;
    
    NSMutableDictionary* PreferredPosition;
    NSInteger TrainingID;
    NSInteger StatBiasID;
    NSInteger GrowthID;
    NSInteger DecayID;
    NSInteger DecayConstantID;
    NSInteger WkOfBirth;
    NSMutableDictionary* TrainingExp;
    double Valuation;
    
    BOOL isGoalKeeper;
    BOOL isInjured;
}
@property NSInteger PlayerID;
@property NSInteger TeamID;
@property NSString* DisplayName;
@property NSString* LastName;
@property NSString* FirstName;
@property NSMutableDictionary* Stats;

@property NSInteger Consistency;
@property NSInteger Potential;
@property NSInteger Form;
@property double Condition;

@property NSMutableDictionary* PreferredPosition;
@property NSInteger TrainingID;
@property NSInteger StatBiasID;
@property NSInteger GrowthID;
@property NSInteger DecayID;
@property NSInteger DecayConstantID;
@property NSInteger WkOfBirth;
@property NSMutableDictionary* TrainingExp;
@property BOOL isGoalKeeper;
@property double Valuation;


- (id) initWithPlayerID:(NSInteger) InputID;
- (BOOL) updatePlayerInDatabaseStats:(BOOL) UpdateStats GameStat:(BOOL)UpdateGameStat Team: (BOOL) UpdateTeam Position: (BOOL) UpdatePosition Valuation:(BOOL) UpdateValuation;
- (BOOL) valuePlayer;

@end
