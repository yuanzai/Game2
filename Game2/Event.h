//
//  Event.h
//  MatchEngine
//
//  Created by Junyuan Lau on 28/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LineUp;
@class Action;
@interface Event : NSObject
@property NSInteger matchMinute;
@property NSInteger eventCount;

@property LineUp* ownTeam;
@property LineUp* oppTeam;
@property BOOL retainTeam;

@property NSMutableArray* eventCommentary;

@property Action* thisAction;
@property Action* previousAction;

@property NSMutableArray* injuryList;

- (void) setEventOwnerTeam1:(LineUp*) team1 Team2:(LineUp*) team2;
- (void) getEvents:(LineUp*) team1 Team2:(LineUp*) team2;

@end
