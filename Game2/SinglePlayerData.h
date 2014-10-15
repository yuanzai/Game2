//
//  SinglePlayerData.h
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@class Fixture;

@interface SinglePlayerData : NSObject <NSCoding>
@property NSInteger SaveGameID;
@property Team* myTeam;
@property Fixture* nextMatch;

@property NSInteger weekdate;
@property NSInteger week;
@property NSInteger season;
@property NSInteger money;

@end
