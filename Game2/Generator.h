//
//  Generator.h
//  MatchEngine
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
@class Player;

@interface Generator : NSObject
@property NSArray* FirstNames;
@property NSArray* LastNames;
@property NSArray* TeamNames;
@property NSArray* TeamNamesSuffix;

- (void) generatePlayersWithSeason:(NSInteger) season;
- (void) generateNewGame;

@end

@interface GeneratePlayer : Player
@property NSArray* FirstNames;
@property NSArray* LastNames;
- (BOOL) createPlayerWithAbility:(NSInteger)ability Potential:(NSInteger) potential Season:(NSInteger) season;
@end
