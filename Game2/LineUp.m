//
//  LineUp.m
//  MatchEngine
//
//  Created by Junyuan Lau on 21/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "LineUp.h"
#import "GlobalVariableModel.h"
#import "Math.h"

@implementation MatchPlayer
@synthesize matchStats, PosCoeff, currentPositionSide, yellow, red, att, def, hasPlayed;


- (id)initWithPlayer:(Player*) thisPlayer;
{
    self = [super init];
    if (self) {
        self = (MatchPlayer*) thisPlayer;
    } return self;
}


- (void) populateMatchStats
{
    if (!matchStats)
        matchStats = [[NSMutableDictionary alloc]init];
    
    [Stats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [matchStats setObject:[NSNumber numberWithDouble:[self getMatchStatWithBaseStat:[obj doubleValue] Consistency:(double) Consistency]] forKey:key];
    }];
    [[self getFormSet] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (Form > 0) {
            [matchStats setObject:MAX([matchStats objectForKey:obj],[NSNumber numberWithDouble:[self getMatchStatWithBaseStat:[obj doubleValue] Consistency:(double) Consistency]])  forKey:obj];
        } else {
            [matchStats setObject:MIN([matchStats objectForKey:obj],[NSNumber numberWithDouble:[self getMatchStatWithBaseStat:[obj doubleValue] Consistency:(double) Consistency]])  forKey:obj];
        }
    }];
    
    att = [self getEventStat:@"ATT"];
    def = [self getEventStat:@"DEF"];
}

- (void) populatePosCoeff
{
    [PreferredPosition objectForKey:[self getPositionString:currentPositionSide]];
    
    if ([[PreferredPosition objectForKey:[self getPositionString:currentPositionSide]]integerValue] == 1) {
        PosCoeff = 1;
    } else {
        if (currentPositionSide.position == Def) {
            if ([[PreferredPosition objectForKey:@"DM"]integerValue]==1) {
                PosCoeff = 0.9;
            } else {
                PosCoeff = 0.8;
            }
        } else if (currentPositionSide.position == SC) {
            if ([[PreferredPosition objectForKey:@"AM"]integerValue]==1) {
                PosCoeff = 0.9;
            } else {
                PosCoeff = 0.8;
            }
        } else {
            PosCoeff = 0.95;
        }
    }
    
    NSInteger left =[[PreferredPosition objectForKey:@"LEFT"]integerValue];
    NSInteger right =[[PreferredPosition objectForKey:@"RIGHT"]integerValue];
    NSInteger centre =[[PreferredPosition objectForKey:@"CENTRE"]integerValue];
    
    if (currentPositionSide.side == Left) {
        PosCoeff +=(left-1) * 0.1;
    }else if (currentPositionSide.side == LeftCentre){
        PosCoeff += (centre-1) * 0.1;
        PosCoeff += ((centre-1) * (left)) * 0.05;
    }else if (currentPositionSide.side == Centre) {
        PosCoeff += (centre-1) * 0.1;
    }else if (currentPositionSide.side == RightCentre) {
        PosCoeff += (centre-1) * 0.1;
        PosCoeff += ((centre-1) * (right)) * 0.05;
    }else if (currentPositionSide.side == Right) {
        PosCoeff += (right-1) * 0.1;
    }
}

- (double) getMatchStatWithBaseStat:(double)stat Consistency:(double) consistency{
    NSDictionary* sdTable = [[NSDictionary alloc]initWithDictionary:[GlobalVariableModel standardDeviationTable]];
    //normal dist 0 mean 1 sd
    double u =(double)(arc4random() %100000 + 1)/100000; //for precision
    double v =(double)(arc4random() %100000 + 1)/100000; //for precision
    double x = sqrt(-2*log(u))*cos(2*M_PI*v);   //or sin(2*pi*v)
    
    //stat constant
    double k2 = 0.05 * (double)consistency + 2 * stat -21;
    double mean = log(24.5 - stat);
    
    //stat sd
    double sd = [[sdTable objectForKey:[NSString stringWithFormat:@"%i",(int)stat]]doubleValue];
    
    //log normal X
    double matchStat = exp(mean + sd * x) + k2;
    matchStat = MAX(matchStat,1);
    matchStat = MIN(matchStat, 30);
    return matchStat;
}

- (NSArray*) getFormSet {
    NSMutableArray* tempArray = [[NSMutableArray alloc]initWithArray:[Stats allKeys]];
    
    int rollCount = Form * (3 + (isGoalKeeper ? -1 : 0));

    NSUInteger count = [tempArray count];
    for (uint i = 0; i < count; ++i)
    {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = arc4random_uniform(nElements) + i;
        [tempArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    NSMutableArray* formSet = [NSMutableArray array];
    for (int i = 0; i < ABS(rollCount); i++) {
        [formSet addObject:[tempArray objectAtIndex:i]];
    }
    return formSet;
}

- (double) getEventStat:(NSString*) type
{
    NSDictionary* eventStatsRecord = [[[DatabaseModel alloc]init] getResultDictionaryForTable:@"statsEvent" withDictionary:
                                      [[NSDictionary alloc]initWithObjectsAndKeys:
                                       @"TYPE",type,
                                       @"POSITION",[self getPositionString:currentPositionSide],
                                       @"SIDE",[self getSideString:currentPositionSide],nil]];
    
    __block double sum = 0.0;
    [matchStats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        sum += [[eventStatsRecord objectForKey:key]doubleValue]*[obj doubleValue];
    }];
    return sum;
}



- (NSString*) getPositionString:(PositionSide) ps
{
    if (ps.position == GKPosition)
        return @"GK";
    if (ps.position == Def)
        return @"Def";
    if (ps.position == DM)
        return @"DM";
    if (ps.position == Mid)
        return @"Mid";
    if (ps.position == AM)
        return @"AM";
    if (ps.position == SC)
        return @"SC";
    return nil;
}

- (NSString*) getSideString:(PositionSide) ps
{
    if (ps.side== Left)
        return @"Left";
    if (ps.side == LeftCentre)
        return @"LeftCentre";
    if (ps.side == Centre)
        return @"Centre";
    if (ps.side == RightCentre)
        return @"RightCentre";
    if (ps.side == Right)
        return @"Right";
    if (ps.side == GKSide)
        return @"GK";
    return nil;
}

@end

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

@synthesize matchLog;

- (void) initWithTeam:(Team*) thisTeam
{
    self.team = thisTeam;
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
    [[currentTactic getAllPlayers]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player* thisPlayer = (Player*) obj;
        if (thisPlayer.Condition <= 0) {
            isValid = NO;
            *stop = YES;
        }
            }];
    return isValid;
}


- (void) populateAllPlayersStats{
    [[currentTactic getAllPlayers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(MatchPlayer*) obj populateMatchStats];
        [(MatchPlayer*) obj populatePosCoeff];
    }];
    
}

- (void) populateSubsStats{
    [currentTactic.SubList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(MatchPlayer*) obj populateMatchStats];
    }];
}

- (void) populateTeamAttDefStats
{
    attTeam = 0.0;
    defTeam = 0.0;
    [[currentTactic getAllPlayers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        attTeam += ((MatchPlayer*) obj).att * ((MatchPlayer*) obj).Condition * ((MatchPlayer*) obj).PosCoeff;
        defTeam += ((MatchPlayer*) obj).def * ((MatchPlayer*) obj).Condition * ((MatchPlayer*) obj).PosCoeff;
    }];
    
    attTeam -= 1000;
    attTeam /= 80;

    defTeam -= 1000;
    defTeam /= 80;

}
@end
