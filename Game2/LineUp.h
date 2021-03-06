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
#import "GameModel.h"
#import "Tactic.h"

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
@property NSInteger subLeft;


@property NSMutableArray* matchLog;
- (id) initWithTeam:(Team*) thisTeam;
- (id) initWithTeamID:(NSInteger) thisTeamID;
- (void) clearTeamProperty;

//Squad
- (void) removeAllPlayers;
- (void) removeInvalidPlayers;
- (void) fillLineup;

//Pre Match
- (void) populateMatchDayForm;
- (BOOL) validateTactic;


//Match
- (void) populateAllPlayersStats;
- (void) populateSubsStats;

//Event
- (void) populateTeamAttDefStats;

//Sub
- (BOOL) subInjured;

//Debug
- (void) printFormation;


@end

