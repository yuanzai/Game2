//
//  Event.m
//  MatchEngine
//
//  Created by Junyuan Lau on 28/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Event.h"
#import "Action.h"
#import "GameModel.h"

@implementation Event
@synthesize matchMinute;
@synthesize eventCount;

@synthesize ownTeam;
@synthesize oppTeam;
@synthesize retainTeam;

@synthesize eventCommentary;

@synthesize thisAction;
@synthesize previousAction;

@synthesize injuryList;

const NSInteger max_action = 10;

- (void) getEvents:(LineUp*) team1 Team2:(LineUp*) team2;
{
    retainTeam = NO;
    [self setEventOwnerTeam1:team1 Team2:team2];
    [self setCommentary];
}

-(void) setEventOwnerTeam1:(LineUp*) team1 Team2:(LineUp*) team2
{
    NSDictionary* factorTable=[[GlobalVariableModel myGlobalVariable] eventOccurenceFactorTable];
    [team1 populateTeamAttDefStats];
    [team2 populateTeamAttDefStats];
    
    double k1 = [[factorTable objectForKey:@"k1"]doubleValue];
    double k2 = [[factorTable objectForKey:@"k2"]doubleValue];
    double kc = [[factorTable objectForKey:@"kc"]doubleValue];
    double ad1 = [[factorTable objectForKey:@"ad1"]doubleValue];
    double ad2 = [[factorTable objectForKey:@"ad2"]doubleValue];
    double probMultiplier = 1.2;
    
    
    double t1Prob = log(ad1+team1.attTeam/(team2.defTeam+ad2))*k2+k1*team1.attTeam + kc;
    double t2Prob = log(ad1+team2.attTeam/(team1.defTeam+ad2))*k2+k1*team2.attTeam + kc;
    //NSLog(@"H A: %.1f D: %.1f P: %.1f|A A: %.1f D: %.1f P: %.1f",homeAttSum,homeDefSum,homeProb,awayAttSum,awayDefSum,awayProb);
    
    if (team1.Location == home) {
        t1Prob *= (probMultiplier + 0.06 + ((double)(arc4random() % 10) / 100));
    } else {
        t1Prob *= probMultiplier;
    }
    
    if (team2.Location == home) {
        t2Prob *= (probMultiplier + 0.06 + ((double)(arc4random() % 10) / 100));
    } else {
        t2Prob *= probMultiplier;
    }
    
    double r = (double) (arc4random() % 10000);
    if (r<10000*t1Prob) {
        ownTeam = team1;
        oppTeam = team2;
    } else if (r<10000*(t1Prob+t2Prob)) {
        ownTeam = team2;
        oppTeam = team1;
    } else {
        ownTeam = nil;
        oppTeam = nil;
    }
    
}

- (void) setCommentary {
    
    eventCommentary = [NSMutableArray array];

    if (!ownTeam) {
        eventCommentary = nil;
        return;
    }    
    // Event probability model
    while(eventCount < max_action){
        thisAction = [[Action alloc]init];
        thisAction.thisTeam = ownTeam;
        thisAction.oppTeam = oppTeam;
        
        if (eventCount > 0)
            thisAction.previousAction = previousAction;
        
        [thisAction setActionProperties];
        previousAction = thisAction;
        
        
        if (thisAction.injuredPlayer) {
            if (!injuryList)
                injuryList = [NSMutableArray array];
            [injuryList addObject:thisAction.injuredPlayer];
        }
        
        eventCount++;

        //actions to continue
        if (thisAction.result == Success) {
            [eventCommentary addObject:thisAction.Commentary];
            continue;
        }
        
        if (thisAction.result == DefenseFoul) {
            [eventCommentary addObject:thisAction.Commentary];
            oppTeam.foul++;
            continue;
        }

        if (thisAction.result == DefenseYellow) {
            [eventCommentary addObject:thisAction.Commentary];
            oppTeam.yellowCard++;
            retainTeam = YES;
            break;
        }
        
        if (thisAction.result == DefenseRed) {
            [eventCommentary addObject:thisAction.Commentary];
            oppTeam.redCard++;
            [oppTeam.currentTactic removePlayerAtPositionSide:thisAction.OppPlayer.currentPositionSide];
            retainTeam = YES;
            break;
        }
        
        if (thisAction.result == Goal) {
            [eventCommentary addObject:thisAction.Commentary];
            ownTeam.shots++;
            ownTeam.score++;
            ownTeam.onTarget++;
            break;
        }

        if (thisAction.result == Fail) {
            [eventCommentary addObject:thisAction.Commentary];
            //ownTeam.shots++;
            //ownTeam.onTarget++;
            break;
        }

        
        if (thisAction.result == Save) {
            [eventCommentary addObject:thisAction.Commentary];
            ownTeam.shots++;
            ownTeam.onTarget++;
            break;
        }
        
        if (thisAction.result == OffTarget) {
            [eventCommentary addObject:thisAction.Commentary];
            ownTeam.shots++;
            break;
        }
        
    }
}
@end