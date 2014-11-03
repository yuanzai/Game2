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
@property NSMutableDictionary* matchStats;
@property double PosCoeff;
@property struct PositionSide currentPositionSide;
@property BOOL yellow;
@property BOOL red;
@property double att;
@property double def;
@property BOOL hasPlayed;
//@property Player* player;

- (id) initWithPlayer:(Player*) thisPlayer;
- (void) populateMatchStats;
- (double) getMatchStatWithBaseStat:(double)stat Consistency:(double) consistency;
@end

@interface LineUp : Team
@property Tactic* currentTactic;
@property Team* team;
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

