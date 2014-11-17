//
//  LineUp.m
//  MatchEngine
//
//  Created by Junyuan Lau on 21/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "LineUp.h"
#import "Team.h"
#import "GlobalVariableModel.h"
#import "Math.h"

@implementation LineUp
@synthesize currentTactic;
@synthesize Location;
@synthesize team;

@synthesize attTeam;
@synthesize defTeam;

@synthesize score;
@synthesize events;
@synthesize shots;
@synthesize onTarget;
@synthesize yellowCard;
@synthesize redCard;
@synthesize foul;
@synthesize offside;
@synthesize subLeft;

@synthesize matchLog;

- (id) initWithTeamID:(NSInteger) thisTeamID
{
    return [self initWithTeam:[[Team alloc]initWithTeamID:thisTeamID]];
}
            
- (id) initWithTeam:(Team*) thisTeam
{
    self = [super init];
    if (self) {
        self.team = thisTeam;
    } return self;
}

- (void) clearTeamProperty
{
    self.events = 0;
    self.score = 0;
    self.shots = 0;
    self.onTarget = 0;
    self.offside = 0;
    self.foul = 0;
    self.yellowCard = 0;
    self.redCard = 0;
}


//TODO: Set Pre Match Form
- (void) populateMatchDayForm
{
    [team.PlayerList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player* thisPlayer = (Player*) obj;
        NSInteger r = arc4random() % 10;
        if (thisPlayer.Form == 0) {
            if (r < 3) {
                thisPlayer.Form = -1;
            } else if (r <6) {
                thisPlayer.Form = 1;
            }
        } else if (abs(thisPlayer.Form) == 1) {
            if (r < 3) {
                thisPlayer.Form = 0;
            } else if (r <6) {
                thisPlayer.Form *= 2;
            }
        } else if (abs(thisPlayer.Form) == 2) {
            if (r < 4) {
                thisPlayer.Form /= 2;
            }
        }
    }];
}

- (BOOL) validateTactic {
    
    __block BOOL isValid = YES;
    __block NSMutableSet* playerList = [NSMutableSet set];
    
    [[currentTactic getAllPlayers]enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.Condition <= 0) {
            isValid = NO;
            *stop = YES;
            //NSLog(@"Player Condition");
        }
        if ([playerList containsObject:p]) {
            isValid = NO;
            *stop = YES;
            //NSLog(@"Player Dupe");
        }
        [playerList addObject:p];

            }];
    if ([[currentTactic getAllPlayers]count]!=11) {
        isValid = NO;
        //NSLog(@"Player Count");
    }
    
    return isValid;
}


- (void) printFormation
{
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            PositionSide ps;
            ps.position = i;
            ps.side = j;
            if ([currentTactic hasPositionAtPositionSide:ps]) {
                NSLog(@"Pos:%i Side:%i Player:%i",ps.position,ps.side,[currentTactic getPlayerAtPositionSide:ps].PlayerID);
            }
        }
    };

}


- (void) populateAllPlayersStats{
    [[currentTactic getAllPlayers] enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        [p populateMatchStats];
        [p populatePosCoeff];
    }];
    
}

- (void) populateSubsStats{
    [currentTactic.SubList enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        [p populateMatchStats];
    }];
}

- (void) populateTeamAttDefStats
{
    attTeam = 0.0;
    defTeam = 0.0;
    [[currentTactic getAllPlayers] enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        attTeam += p.att * p.Condition * p.PosCoeff;
        defTeam += p.def * p.Condition * p.PosCoeff;
    }];
    
    attTeam -= 1000;
    attTeam /= 80;

    defTeam -= 1000;
    defTeam /= 80;

}

- (void) removeInvalidPlayers
{
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            PositionSide ps;
            ps.position = i;
            ps.side = j;
            if ([currentTactic hasPlayerAtPositionSide:ps]) {
                Player* thisPlayer = [currentTactic getPlayerAtPositionSide:ps];
                if (thisPlayer.Condition <= 0 || thisPlayer.TeamID != team.TeamID) {
                    [currentTactic removePlayerAtPositionSide:ps];
                }
            }
        }
    };
}

- (void) removeAllPlayers
{
    currentTactic.GoalKeeper = nil;
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            PositionSide ps;
            ps.position = i;
            ps.side = j;
            if ([currentTactic hasPlayerAtPositionSide:ps]) {
                [currentTactic removePlayerAtPositionSide:ps];
            }
        }
    };
    
}

- (BOOL) isInStartingLineUp:(Player*) thisPlayer
{
    if (thisPlayer.PlayerID == currentTactic.GoalKeeper.PlayerID)
        return YES;
    
    for (int i = 0; i < 5;i++) {
        for (int j = 0; j < 5;j++) {
            PositionSide ps;
            ps.position = i;
            ps.side = j;
            if ([currentTactic hasPlayerAtPositionSide:ps]) {
                if ([currentTactic getPlayerAtPositionSide:ps].PlayerID == thisPlayer.PlayerID)
                    return YES;
            }
        }
    };
    return NO;
}

- (BOOL) subPlayer:(Player*) thisPlayer Sub:(Player*)sub
{
    if (subLeft ==0)
        return NO;
    if (![[currentTactic getAllPlayers] containsObject:thisPlayer])
        return NO;
    
    [currentTactic removePlayerAtPositionSide:thisPlayer.currentPositionSide];
    [currentTactic populatePlayer:sub PositionSide:thisPlayer.currentPositionSide ForceSwap:NO];
    return YES;
}

#pragma mark AI Generators

- (BOOL) subInjured
{
    __block BOOL result = NO;
    if (currentTactic.GoalKeeper.Condition ==0) {
        NSMutableArray* gkArray = [[NSMutableArray alloc]initWithArray:[self getGKSubArray]];
        if ([gkArray count] > 0) {
            currentTactic.GoalKeeper = [gkArray objectAtIndex:0];
            currentTactic.GoalKeeper.hasPlayed = YES;
            result = YES;
        }
    }
    
    

    [[currentTactic getOutFieldPlayers]enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.Condition ==0) {
            [currentTactic removePlayerAtPositionSide:p.currentPositionSide];
            subLeft--;
        }
        if (subLeft ==0) {
            *stop = YES;
        }
        
    }];
    
    __block NSMutableArray* outfieldArray = [[NSMutableArray alloc]initWithArray:[self getOutfieldSubArray]];
    
    [outfieldArray enumerateObjectsUsingBlock:^(Player *p, NSUInteger idx, BOOL *stop) {
        if ([self fillPlayer:p CoeffThreshold:1.0]) {
            [outfieldArray removeObjectAtIndex:idx];
            p.hasPlayed = YES;
            result = YES;
        } else {
            if ([self swapToFillPlayer:p]){
                [outfieldArray removeObjectAtIndex:idx];
                p.hasPlayed = YES;
                result = YES;
            }
        }
        if([self validateTactic])
            *stop =YES;
    }];
    
    if (![self validateTactic]) {
        [outfieldArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
            if ([self fillPlayer:p CoeffThreshold:0.9]) {
                [outfieldArray removeObjectAtIndex:idx];
                p.hasPlayed = YES;
                result = YES;
            }
            if([self validateTactic])
                *stop =YES;
        }];
    }
    if (![self validateTactic]) {
        [outfieldArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
            if ([self fillPlayer:p CoeffThreshold:0.7]) {
                [outfieldArray removeObjectAtIndex:idx];
                p.hasPlayed = YES;
                result = YES;
            }
            if([self validateTactic])
                *stop =YES;
        }];
    }
    return result;
}


- (void) fillGoalkeeper
{
    NSMutableArray* sortedArray = [[NSMutableArray alloc]initWithArray:[team.PlayerList sortedArrayUsingComparator:^NSComparisonResult(Player* a, Player* b) {
        return [@(b.Valuation) compare:@(a.Valuation)];
    }]];
    
    [sortedArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.isGoalKeeper) {
            currentTactic.GoalKeeper = p;
            *stop = YES;
        }
    }];
}

- (void) fillOutfieldPlayers
{
    NSMutableArray* players = [self getOutfieldPlayerArray];
    [players enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {        
        if (![self fillPlayer:p CoeffThreshold:1.0]) {
            if (![self swapToFillPlayer:p])
                if(![self fillPlayer:p CoeffThreshold:0.9])
                    [self fillPlayer:p CoeffThreshold:0.7];
        }
    }];
    
}

- (BOOL) fillPlayer:(Player*) thisPlayer CoeffThreshold:(double) threshold
{

    for (int i = 4; i >=0; i--) {
        for (int j = 4; j >= 0; j--) {
            if ((i == 4 && j == 4) || (i == 4 && j == 0))
                continue;
            PositionSide ps = (PositionSide){i ,j};
            if ([thisPlayer getPositionCoeffForPositionSide:ps] >= threshold-0.01) {
                if ([self checkAndFillPositionSide:ps forPlayer:thisPlayer]) {
                    return YES;
                }
            }
            
        }
    }
    return NO;
}

- (BOOL) swapToFillPlayer:(Player*) thisPlayer
{
    for (int i = 4; i >=0; i--) {
        for (int j = 4; j >= 0; j--) {
            PositionSide ps = {i,j};
            if ([thisPlayer getPositionCoeffForPositionSide:ps] == 1) {
                Player* existing = [currentTactic getPlayerAtPositionSide:ps];
                if ([self fillPlayer:existing CoeffThreshold:1.0]){
                    [currentTactic removePlayerAtPositionSide:ps];
                    return [currentTactic populatePlayer:thisPlayer PositionSide:ps ForceSwap:NO];
                }
                
            }
        }
    }
    return NO;
}

- (BOOL) checkAndSwapToPositionSide:(PositionSide) ps forPlayer:(Player*) thisPlayer
{
    if ([currentTactic hasPositionAtPositionSide:ps] &&
        ![currentTactic hasPlayerAtPositionSide:ps]) {
        [currentTactic populatePlayer:thisPlayer PositionSide:ps ForceSwap:NO];
        return YES;
    }
    return NO;
}



- (BOOL) checkAndFillPositionSide:(PositionSide) ps forPlayer:(Player*) thisPlayer
{
    if ([currentTactic hasPositionAtPositionSide:ps] &&
        ![currentTactic hasPlayerAtPositionSide:ps]) {
        [currentTactic populatePlayer:thisPlayer PositionSide:ps ForceSwap:NO];
        return YES;
    }
    return NO;
}

- (NSMutableArray*) getOutfieldPlayerArray
{
    NSMutableArray* sortedArray = [[NSMutableArray alloc]initWithArray:[team.PlayerList sortedArrayUsingComparator:^NSComparisonResult(Player* a, Player* b) {
        return [@(b.Valuation) compare:@(a.Valuation)];
    }]];
    NSMutableArray* result = [NSMutableArray array];
    [sortedArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (!p.isGoalKeeper)
            [result addObject:p];
    }];
    
    return result;
}

- (NSMutableArray*) getOutfieldSubArray
{
    NSMutableArray* sortedArray = [[NSMutableArray alloc]initWithArray:[currentTactic.SubList sortedArrayUsingComparator:^NSComparisonResult(Player* a, Player* b) {
        return [@(b.Valuation) compare:@(a.Valuation)];
    }]];
    NSMutableArray* result = [NSMutableArray array];
    [sortedArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (!p.isGoalKeeper && !p.hasPlayed)
            [result addObject:p];
    }];
    
    return result;
}

- (NSMutableArray*) getGKSubArray
{
    NSMutableArray* sortedArray = [[NSMutableArray alloc]initWithArray:[currentTactic.SubList sortedArrayUsingComparator:^NSComparisonResult(Player* a, Player* b) {
        return [@(b.Valuation) compare:@(a.Valuation)];
    }]];
    NSMutableArray* result = [NSMutableArray array];
    [sortedArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.isGoalKeeper && !p.hasPlayed)
            [result addObject:p];
    }];
    
    return result;
}

- (NSArray*) getArrayByValueForPosition:(PositionSide) ps
{
    NSMutableArray* resultArray = [NSMutableArray array];
    NSMutableArray* sortedArray = [[NSMutableArray alloc]initWithArray:[team.PlayerList sortedArrayUsingComparator:^NSComparisonResult(Player* a, Player* b) {
        return [@(b.Valuation) compare:@(a.Valuation)];
    }]];
    return nil;
}
@end
