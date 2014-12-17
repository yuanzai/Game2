//
//  LineUp.m
//  MatchEngine
//
//  Created by Junyuan Lau on 21/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "LineUp.h"
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
    
    if (!currentTactic.GoalKeeper) {
        isValid = NO;
        NSLog(@"No GK");
    }
    
    [[currentTactic getAllPlayers]enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.Condition <= 0) {
            isValid = NO;
            *stop = YES;
            NSLog(@"Player Condition");
        }
        if ([playerList containsObject:p]) {
            isValid = NO;
            *stop = YES;
            NSLog(@"Player Dupe");
        }
        [playerList addObject:p];

            }];
    if ([[currentTactic getAllPlayers]count]!=11-redCard) {
        isValid = NO;
        NSLog(@"Player Count");
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
    if (currentTactic.GoalKeeper.TeamID != team.TeamID)
        currentTactic.GoalKeeper = nil;
    
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
    currentTactic.SubList = [NSMutableArray array];
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

- (void) fillLineup
{
    [self removeAllPlayers];
    [self fillGoalkeeper];
    [self fillOutfieldPlayers];
}

- (void) fillGoalkeeper
{
    if (!currentTactic.SubList)
        currentTactic.SubList = [NSMutableArray array];
    
    NSMutableArray* sortedArray = [[NSMutableArray alloc]initWithArray:[team.PlayerList sortedArrayUsingComparator:^NSComparisonResult(Player* a, Player* b) {
        return [@(b.Valuation) compare:@(a.Valuation)];
    }]];
    
    //Starting GK
    [sortedArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.isGoalKeeper) {
            currentTactic.GoalKeeper = p;
            [sortedArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];

    //Sub GK
    [sortedArray enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if (p.isGoalKeeper) {
            [currentTactic.SubList addObject:p];
            [sortedArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
}

- (void) fillOutfieldPlayers
{
    __block NSInteger sc = 2;
    __block NSInteger mid = 2;
    __block NSInteger def = 2;
    
    NSMutableArray* players = [self getOutfieldPlayerArray];
    [players enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if ([self fillPlayer:p CoeffThreshold:1.0]) {
            [players removeObjectAtIndex:idx];
        } else {
            if ([self swapToFillPlayer:p]) {
                [players removeObjectAtIndex:idx];
            }else {
                if([self fillPlayer:p CoeffThreshold:0.9]) {
                    [players removeObjectAtIndex:idx];
                    
                } else {
                    if ([self fillPlayer:p CoeffThreshold:0.7])
                        [players removeObjectAtIndex:idx];
                }
            }
        }
    }];
    
    
    [players enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
        if ([currentTactic.SubList count]>=7)
            *stop = YES;
        if ([[p.PreferredPosition objectForKey:@"SC"]integerValue]==1 && sc > 0){
            sc--;
            [currentTactic.SubList addObject:p];
        } else if (([[p.PreferredPosition objectForKey:@"AM"]integerValue]==1 ||
                    [[p.PreferredPosition objectForKey:@"MID"]integerValue]==1 ||
                    [[p.PreferredPosition objectForKey:@"DM"]integerValue]==1) && mid > 0){
            mid--;
            [currentTactic.SubList addObject:p];
        } else if (def>0) {
            def--;
            [currentTactic.SubList addObject:p];
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

@end
