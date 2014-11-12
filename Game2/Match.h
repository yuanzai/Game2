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
{
    LineUp *team1;
    LineUp *team2;
    Fixture* thisFixture;
    NSInteger matchMinute;
    
    BOOL isPaused;
    BOOL isOver;
    
    BOOL retainTeam;
    Action* lastAction;
}
@property LineUp *team1;
@property LineUp *team2;

@property Fixture* thisFixture;
@property NSInteger matchMinute;
@property BOOL isPaused;
@property BOOL hasExtraTime;
@property BOOL isOver;
@property BOOL retainTeam;
@property Action* lastAction;

- (id) initWithFixture:(Fixture*) fixture WithSinglePlayerTeam:(LineUp*) sp;

- (BOOL) startMatch;
- (NSArray*) nextMinute;
- (void) printScore;
- (void) endMatch;

- (void) pauseMatch;
- (void) resumeMatch;
- (void) upPlayerStats;

- (BOOL) subIn:(Player*) sub ForPlayer:(Player*) player;

- (void) playFullGame;
- (void) UpdateMatchFixture;
@end
