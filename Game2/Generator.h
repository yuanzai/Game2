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
@property NSArray* AgeDistribution;

- (void) generateNewGameWithTeamName:(NSString*) myTeamName;

- (void) generatePlayersWithSeason:(NSInteger) season NumberOfPlayers:(NSInteger) number;

@end

@interface GeneratePlayer : Player
@property NSArray* FirstNames;
@property NSArray* LastNames;
- (BOOL) createPlayerWithAbility:(NSInteger)ability Potential:(NSInteger) potential Season:(NSInteger) season;
+ (double) addToRuntime:(int)no amt:(double) amt;
@end