//
//  Match.h
//  MatchEngine
//
//  Created by Junyuan Lau on 29/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LineUp;
@class Action;
@class Fixture;
@class Player;
@interface Match : NSObject
@property LineUp *team1;
@property LineUp *team2;

@property LineUp *spTeam;
@property BOOL hasSP;

@property Fixture* thisFixture;
@property NSInteger matchMinute;
@property BOOL isPaused;
@property BOOL hasExtraTime;
@property BOOL isOver;
@property BOOL retainTeam;
@property Action* lastAction;
@property NSMutableArray* preCommentary;
@property NSMutableArray* postCommentary;


- (id) initWithFixture:(Fixture*) fixture WithSinglePlayerTeam:(LineUp*) sp;

- (BOOL) startMatch;
- (NSArray*) nextMinute;
- (void) pauseMatch;
- (void) resumeMatch;
- (void) endMatch;

- (BOOL) subIn:(Player*) sub ForPlayer:(Player*) player;

- (void) printMatch;



// AI
- (void) playFullGame;

//CRUD
- (void) updateMatchFixture;
- (void) updatePlayerData;
@end
