//
//  LineUp.h
//  MatchEngine
//
//  Created by Junyuan Lau on 21/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
#import "Team.h"
#import "Player.h"
#import "DatabaseModel.h"

typedef enum {
    home,
    away,
    neutral
} VenueType;


@interface LineUp : NSObject
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
- (id) initWithTeam:(Team*) thisTeam;
- (id) initWithTeamID:(NSInteger) thisTeamID;

//Squad
- (void) removeAllPlayers;
- (void) fillGoalkeeper;
- (void) fillOutfieldPlayers;

//Pre Match
- (void) populateMatchDayForm;
- (BOOL) validateTactic;


//Match
- (void) populateAllPlayersStats;
- (void) populateSubsStats;

//Event
- (void) populateTeamAttDefStats;

//Debug
- (void) printFormation;


@end

