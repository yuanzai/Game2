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
#import "GameModel.h"

@implementation Match
@synthesize team1;
@synthesize team2;
@synthesize hasSP;

@synthesize thisFixture;
@synthesize matchMinute;
@synthesize isPaused;
@synthesize hasExtraTime;
@synthesize isOver;
@synthesize retainTeam;
@synthesize lastAction;
@synthesize preCommentary;
@synthesize postCommentary;


- (id) initWithFixture:(Fixture*) fixture WithSinglePlayerTeam:(LineUp*) sp
{
    if (!fixture)
        [NSException raise:@"No fixture" format:@"no fixture"];
    self = [super init];
    if (self ) {
        thisFixture = fixture;
        if (fixture.HOMETEAM == 0) {
            team1 = sp;
            team1.Location = home;
            hasSP = YES;
        } else {
            team1 = [[LineUp alloc]initWithTeam:[[[GameModel myGlobalVariableModel] teamList]objectForKey:[NSString stringWithFormat:@"%i",fixture.HOMETEAM]]];
            team1.Location = home;
            team1.currentTactic = [[Tactic alloc]initWithTacticID:2];
            [team1 populateMatchDayForm];
            [team1 fillLineup];
        }
        
        if (fixture.AWAYTEAM == 0) {
            team2 = sp;
            team2.Location = away;
            hasSP = YES;
        } else {
            team2 = [[LineUp alloc]initWithTeam:[[[GameModel myGlobalVariableModel] teamList]objectForKey:[NSString stringWithFormat:@"%i",fixture.AWAYTEAM]]];
            team2.Location = away;
            team2.currentTactic = [[Tactic alloc]initWithTacticID:2];
            [team2 populateMatchDayForm];
            [team2 fillLineup];
        }
        [team1 clearTeamProperty];
        [team1 populateAllPlayersStats];
        [team1 populateSubsStats];
        [team1 populateTeamAttDefStats];
        
        [team2 clearTeamProperty];
        [team2 populateAllPlayersStats];
        [team2 populateSubsStats];
        [team2 populateTeamAttDefStats];
    } return self;
}


- (BOOL) startMatch
{
    if (team1 == nil || team2 == nil)
        return NO;
    
    if (![team1 validateTactic] || ![team2 validateTactic])
        return NO;
    
    isPaused = NO;
    isOver = NO;
    matchMinute = 0;
    return YES;
}

- (NSArray*) nextMinute
{
    matchMinute++;
    
    
    NSMutableArray* minuteEvent = [NSMutableArray array];

    if ([preCommentary count] > 0) {
        minuteEvent = [[NSMutableArray alloc]initWithArray:preCommentary copyItems:YES];
    }
    preCommentary = nil;
    [minuteEvent addObjectsFromArray:[self getMinuteEvent]];
    
    
    
    if (matchMinute == 45 || matchMinute == 90 || matchMinute == 105 || matchMinute == 120) {
        while (retainTeam) {
            [minuteEvent addObjectsFromArray:[self getMinuteEvent]];
        }
    }
    
    [self updateFatigue];
    [self setPostCommentary];

    if ([postCommentary count] > 0)
        [minuteEvent addObject:postCommentary];
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
    
    if ([thisEvent.injuryList count] > 0) {
        __block BOOL hasSPInjury = NO;
        __block BOOL hasComInjury = NO;

        [thisEvent.injuryList enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
            if (p.TeamID==0) {
                hasSPInjury = YES;
            }
            if (p.TeamID !=0)
                hasComInjury = YES;
        }];
        
        if (hasComInjury) {
            if (!preCommentary)
                preCommentary = [NSMutableArray array];
            if (team1.team.TeamID !=0){
                [team1 subInjured];
                [preCommentary addObject:[NSString stringWithFormat:@"Substitution made by %@",team1.team.Name] ];
            }
            if (team2.team.TeamID !=0)
                [team2 subInjured];
                [preCommentary addObject:[NSString stringWithFormat:@"Substitution made by %@",team2.team.Name]];
        }
        
        if (thisEvent.ownTeam.team.TeamID ==0) {
            isPaused = YES;
        }
    }
    
    return thisEvent.eventCommentary;
}

- (void) updateFatigue
{
    [[team1.currentTactic getAllPlayers]enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        double factor = 0.0;
        
        if (p.currentPositionSide.position == GKPosition) {
            factor = 0.1;
        } else if (p.currentPositionSide.position == Def) {
            factor = 0.7;
        } else if (p.currentPositionSide.position == DM) {
            factor = 1;
        } else if (p.currentPositionSide.position == Mid) {
            factor = 1;
        } else if (p.currentPositionSide.position == AM) {
            factor = 0.9;
        } else if (p.currentPositionSide.position == SC) {
            factor = 0.7;
        }
        
        double fitFactor = ((60.0 - [[p.matchStats objectForKey:@"FIT"]doubleValue]) * 0.005);
        double worFactor = ([[p.matchStats objectForKey:@"WOR"]doubleValue] * .002);
        
        factor = (fitFactor + worFactor) * ((arc4random() % 25 + 75)/100 * factor) / 100;
        p.Condition -= factor;
    }];
}

- (void) setPreCommentary
{
    // This is for the next minute, not current minute
    
}

- (void) setPostCommentary{
    postCommentary = [NSMutableArray array];
    if (matchMinute == 45) {
        isPaused = YES;
        [postCommentary addObject:@"Half Time"];
        
    } else if (matchMinute == 90) {
        if (thisFixture.HASET == 1 && team1.score == team2.score) {
            isPaused = YES;
            [postCommentary addObject:@"End of 90 Min Time"];
        } else {
            isOver = YES;
            [postCommentary addObject:@"Full Time"];
        }
    } else if (matchMinute == 105) {
        isPaused = YES;
        [postCommentary addObject:@"Extra Time Half Time"];
    } else if (matchMinute == 120) {
        isOver = YES;
        [postCommentary addObject:@"Extra Time Full Time"];
    }
}

- (void) endMatch
{
    [self printMatch];
}

- (BOOL) subIn:(Player*) sub ForPlayer:(Player*) player
{
    if (sub.hasPlayed)
        return NO;
    Player* tempPlayer;
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

- (void) playFullGame
{
    [self startMatch];
    while (!isOver) {
        if(isPaused) {
            [self resumeMatch];
            
        }
        [self nextMinute];
    }
}

- (void) updateMatchFixture
{
    thisFixture.HOMESCORE = team1.score;
    thisFixture.AWAYSCORE = team2.score;
    thisFixture.HOMEYELLOW = team1.yellowCard;
    thisFixture.AWAYYELLOW = team2.yellowCard;
    thisFixture.HOMERED = team1.redCard;
    thisFixture.AWAYRED = team2.redCard;
    thisFixture.PLAYED = 1;
    [thisFixture updateFixtureInDatabase];
}

- (void) updatePlayerData
{
    
}

- (void) printMatch
{
    NSLog(@"%i t1:%i t2:%i %i - %i", thisFixture.MATCHID, thisFixture.HOMETEAM, thisFixture.AWAYTEAM, team1.score, team2.score);
}
@end
