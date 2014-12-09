//
//  Team.h
//  MatchEngine
//
//  Created by Junyuan Lau on 17/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@class Player;
@class Tournament;
@interface Team : NSObject

@property NSInteger TeamID;
@property NSString* Name;
@property NSInteger TournamentID;

@property NSMutableArray* PlayerList;
@property NSMutableSet* PlayerIDList;
@property NSMutableDictionary* PlayerDictionary;
@property BOOL isSinglePlayer;
@property Tournament* leagueTournament;

- (id) initWithTeamID:(NSInteger) InputID;
- (void) updateFromDatabase;
- (BOOL) updateToDatabase;
- (Player*) getPlayerWithID:(NSInteger) PlayerID;
- (void) updateConditionPreGame;

- (void) transferActivity;

//Querying
- (NSArray*) getAllPlayersSortByValuation;
- (NSArray*) getAllGKWithInjured:(BOOL) withInjured;
- (NSArray*) getAllOutfieldWithInjured:(BOOL) withInjured;;
@end
