//
//  Match.m
//  MatchEngine
//
//  Created by Junyuan Lau on 29/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Match.h"
#import "Event.h"
#import "LineUp.h"
#import "Fixture.h"

@implementation Match
@synthesize team1;
@synthesize team2;

@synthesize thisFixture;
@synthesize matchMinute;
@synthesize isPaused;
@synthesize hasExtraTime;
@synthesize isOver;
@synthesize retainTeam;
@synthesize lastAction;

- (BOOL) startMatch
{
    if (team1 == nil || team2 == nil)
        return NO;
    
    isPaused = NO;
    isOver = NO;
    matchMinute = 0;
    NSLog(@"Kick Off");
    return YES;
}

- (NSArray*) nextMinute
{
    matchMinute++;
    NSMutableArray* minuteEvent = [[NSMutableArray alloc]initWithArray:[self getMinuteEvent]];
    
    if (matchMinute == 45 || matchMinute == 90 || matchMinute == 105 || matchMinute == 120) {
        while (retainTeam) {
            [minuteEvent addObjectsFromArray:[self getMinuteEvent]];
        }
    }
    
    [self updateFatigue];
    if ([self getCommentaryForMinute])
        [minuteEvent addObject:[self getCommentaryForMinute]];
    return minuteEvent;
}

- (NSArray*) getMinuteEvent {
    Event* thisEvent = [[Event alloc]init];
    
    if (retainTeam) {
        retainTeam = NO;
        thisEvent.previousAction = lastAction;
        thisEvent.eventCount = 1;
    }
    
    [thisEvent getEvents:team1 Team2:team2];
    
    if (thisEvent.retainTeam) {
        retainTeam = YES;
        lastAction = thisEvent.thisAction;
    }
    return thisEvent.eventCommentary;
}

- (void) updateFatigue
{
    [[team1.currentTactic getAllPlayers]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        double factor = 0.0;
        
        if (((MatchPlayer*) obj).currentPositionSide.position == GKPosition) {
            factor = 0.1;
        } else if (((MatchPlayer*) obj).currentPositionSide.position == Def) {
            factor = 0.7;
        } else if (((MatchPlayer*) obj).currentPositionSide.position == DM) {
            factor = 1;
        } else if (((MatchPlayer*) obj).currentPositionSide.position == Mid) {
            factor = 1;
        } else if (((MatchPlayer*) obj).currentPositionSide.position == AM) {
            factor = 0.9;
        } else if (((MatchPlayer*) obj).currentPositionSide.position == SC) {
            factor = 0.7;
        }
        
        double fitFactor = ((60.0 - [[((MatchPlayer*) obj).matchStats objectForKey:@"FIT"]doubleValue]) * 0.005);
        double worFactor = ([[((MatchPlayer*) obj).matchStats objectForKey:@"WOR"]doubleValue] * .002);
        
        factor = (fitFactor + worFactor) * ((arc4random() % 25 + 75)/100 * factor) / 100;
        ((MatchPlayer*) obj).Condition -= factor;
    }];
}

- (NSString* ) getCommentaryForMinute{
    if (matchMinute == 45) {
        isPaused = YES;
        return @"Half Time";
    } else if (matchMinute == 90) {
        if (thisFixture.hasExtraTime && team1.score == team2.score) {
            isPaused = YES;
            return @"End of 90 Min Time";
        } else {
            isOver = YES;
            return @"Full Time";
        }
    } else if (matchMinute == 105) {
        isPaused = YES;
        return @"Extra Time Half Time";
    } else if (matchMinute == 120) {
        isOver = YES;
        return @"Extra Time Full Time";
    }
    return nil;
}


- (void) printScore
{
    
}

- (void) endMatch
{
    [self printScore];
}

- (void) upPlayerStats {
    
}

- (BOOL) subIn:(MatchPlayer*) sub ForPlayer:(MatchPlayer*) player
{
    if (sub.hasPlayed)
        return NO;
    MatchPlayer* tempPlayer;
    tempPlayer = sub;
    sub = player;
    player = tempPlayer;
    player.hasPlayed = YES;
    return YES;
}

- (void) pauseMatch
{
    isPaused = YES;
}
- (void) resumeMatch
{
    isPaused = NO;
}

@end
