//
//  Team.h
//  MatchEngine
//
//  Created by Junyuan Lau on 17/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Player;
@class Tournament;
@interface Team : NSObject

@property NSInteger TeamID;
@property NSString* Name;
@property NSInteger TournamentID;

@property NSMutableArray* PlayerList;
@property NSMutableArray* PlayerIDList;
@property NSMutableDictionary* PlayerDictionary;
@property NSMutableDictionary* tableData;
@property BOOL isSinglePlayer;
@property Tournament* tournament;

- (id) initWithTeamID:(NSInteger) InputID;
- (void) updateFromDatabase;
- (BOOL) updateToDatabase;
- (Player*) getPlayerWithID:(NSInteger) PlayerID;
- (void) updateConditionPreGame;
@end
