//
//  LineUp.h
//  MatchEngine
//
//  Created by Junyuan Lau on 21/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Team.h"
#import "Player.h"
#import "Tactic.h"
#import "DatabaseModel.h"

typedef enum {
    home,
    away,
    neutral
} VenueType;

@interface MatchPlayer : Player
{
    NSMutableDictionary* matchStats;
    double PosCoeff;
    struct PositionSide currentPositionSide;
    BOOL yellow;
    BOOL red;
    double att;
    double def;
    
    BOOL hasPlayed;
}
@property NSMutableDictionary* matchStats;
@property double PosCoeff;
@property struct PositionSide currentPositionSide;
@property BOOL yellow;
@property BOOL red;
@property double att;
@property double def;
@property BOOL hasPlayed;


- (void) populateMatchStats;
- (double) getMatchStatWithBaseStat:(double)stat Consistency:(double) consistency;
@end

@interface LineUp : Team
{
    Tactic* currentTactic;
    VenueType Location;
    double attTeam;
    double defTeam;
    
    NSInteger score;
    NSInteger events;
    NSInteger shots;
    NSInteger onTarget;
    NSInteger yellowCard;
    NSInteger redCard;
    NSInteger foul;
    NSInteger offside;
    
    NSMutableArray* matchLog;
}

@property Tactic* currentTactic;
@property VenueType Location;
@property double attTeam;
@property double defTeam;

@property NSInteger score;
@property NSInteger events;
@property NSInteger shots;
@property NSInteger onTarget;
@property NSInteger yellowCard;
@property NSInteger redCard;
@property NSInteger foul;
@property NSInteger offside;

@property NSMutableArray* matchLog;

//Pre Match
- (void) populateMatchDayForm;

//Match
- (void) populateAllPlayersStats;
- (void) populateSubsStats;

//Event
- (void) populateTeamAttDefStats;

@end

