//
//  Scouting.m
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Scouting.h"
#import "GameModel.h"
#import "DatabaseModel.h"
#import "Team.h"

@implementation Scouting

@synthesize scoutArray, shortListID, shortListLimit, myGame, lastRun;

- (id) init
{
    self = [super init];
    if (self){
        scoutArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i ++) {
            [scoutArray addObject:[Scout new]];
        }
        shortListLimit = 50;
    }; return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.scoutArray = [decoder decodeObjectForKey:@"scoutArray"];
    self.shortListID = [decoder decodeObjectForKey:@"shortListID"];
    self.shortListLimit = [decoder decodeIntegerForKey:@"shortListLimit"];
    self.lastRun = [decoder decodeIntegerForKey:@"lastRun"];

    [scoutArray enumerateObjectsUsingBlock:^(Scout* s, NSUInteger idx, BOOL *stop) {
        s.myGame = myGame;
    }];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.scoutArray forKey:@"scoutArray"];
    [encoder encodeObject:self.shortListID forKey:@"shortListID"];
    [encoder encodeInteger:self.shortListLimit forKey:@"shortListLimit"];
    [encoder encodeInteger:self.lastRun forKey:@"lastRun"];
}

- (NSArray*) getShortList
{
    __block NSMutableArray* shortList = [NSMutableArray array];
    [shortListID enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Player* p = [[GlobalVariableModel myGlobalVariable]getPlayerFromID:[obj integerValue]];
        if (p.TeamID !=0) {
            [shortList addObject:p];
        } else {
            [shortListID removeObjectAtIndex:idx];
        }
    }];
    return shortList;
}

- (void) addPlayerToShortList:(Player*)player
{
    [shortListID enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj integerValue] == player.PlayerID) {
            *stop = YES;
            return;
        }
    }];
    [shortListID addObject:@(player.PlayerID)];
}

- (void) removeFromShortList:(Player*)player
{
    [shortListID enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj integerValue] == player.PlayerID) {
            [shortListID removeObjectAtIndex:idx];
            *stop = YES;
            return;
        }
    }];
}

- (NSArray*) getAllScoutsResults
{
    NSMutableSet* resultSet = [NSMutableSet set];
    [scoutArray enumerateObjectsUsingBlock:^(Scout* s, NSUInteger idx, BOOL *stop) {
        if (s.ISACTIVE) {
            if (s.scoutResults) {
                [resultSet addObjectsFromArray:s.scoutResults];
            }
        }
    }];
    return [resultSet allObjects];
}

- (void) addPlayersFromResultToShortlist
{
    [scoutArray enumerateObjectsUsingBlock:^(Scout* s, NSUInteger idx, BOOL *stop) {
        if (s.ISACTIVE) {
            if (s.scoutResults) {
                [s.scoutResults enumerateObjectsUsingBlock:^(Player* p, NSUInteger idx, BOOL *stop) {
                    [self addPlayerToShortList:p];
                }];
            }
        }
    }];
}

- (void) removeExcessPlayersFromShortlist
{
    if ([shortListID count] > shortListLimit) {
        NSInteger toRemove =[shortListID count] - shortListLimit;
        for (NSInteger i = 0; i<toRemove; i++) {
            [shortListID removeObjectAtIndex:i];
        }
    }
}

- (void) runAllScouting
{
    [scoutArray enumerateObjectsUsingBlock:^(Scout* s, NSUInteger idx, BOOL *stop) {
        if (s.ISACTIVE && s.isScoutingSuccess) {
            s.scoutResults = [NSMutableArray array];
            [s.scoutResults addObjectsFromArray:[s getScoutingPlayerArray]];
        }
    }];
    lastRun = myGame.myData.weekdate;
}

@end

@implementation Scout
@synthesize NAME;
@synthesize JUDGEMENT; // judging ability + potential
@synthesize YOUTH; // judging potential in < 23yr olds
@synthesize VALUE; // abilty to price ratio
@synthesize KNOWLEDGE; // useful perks spotting
@synthesize DILIGENCE; // probabilty of more names
@synthesize ISACTIVE;
@synthesize SCOUTTYPE; // scout type
@synthesize SCOUTPOSITION; // scout type
@synthesize scoutResults;
@synthesize valueArray;
@synthesize myGame;

- (id)init {
    self = [super init];
    if (self) {
        myGame = [GameModel myGame];
        SCOUTPOSITION = ScoutAny;
        SCOUTTYPE = SquadPlayer;
        ISACTIVE = NO;
    }; return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.JUDGEMENT = [decoder decodeIntegerForKey:@"JUDGEMENT"];
    self.YOUTH = [decoder decodeIntegerForKey:@"YOUTH"];
    self.VALUE = [decoder decodeIntegerForKey:@"VALUE"];
    self.KNOWLEDGE = [decoder decodeIntegerForKey:@"KNOWLEDGE"];
    self.DILIGENCE = [decoder decodeIntegerForKey:@"DILIGENCE"];
    self.NAME = [decoder decodeObjectForKey:@"NAME"];

    self.SCOUTTYPE = [decoder decodeIntegerForKey:@"SCOUTTYPE"];
    self.SCOUTPOSITION = [decoder decodeIntegerForKey:@"SCOUTPOSITION"];
    self.ISACTIVE = [decoder decodeIntegerForKey:@"ISACTIVE"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.JUDGEMENT forKey:@"JUDGEMENT"];
    [encoder encodeInteger:self.YOUTH forKey:@"YOUTH"];
    [encoder encodeInteger:self.VALUE forKey:@"VALUE"];
    [encoder encodeInteger:self.KNOWLEDGE forKey:@"KNOWLEDGE"];
    [encoder encodeInteger:self.DILIGENCE forKey:@"DILIGENCE"];
    [encoder encodeObject:self.NAME forKey:@"NAME"];
    
    [encoder encodeInteger:self.SCOUTTYPE forKey:@"SCOUTTYPE"];
    [encoder encodeInteger:self.SCOUTPOSITION forKey:@"SCOUTPOSITION"];
    [encoder encodeInteger:self.ISACTIVE forKey:@"ISACTIVE"];

}


- (BOOL) isScoutingSuccess
{
    NSInteger success;
    switch (SCOUTTYPE) {
        case StarPlayer:
            success = 120;
            break;
        case SquadPlayer:
            success = 200;
            break;
        case Youth:
            success = 170;
            break;
        default:
            break;
    }
    if (SCOUTPOSITION != ScoutAny) {
        success /= 2;
    }
    success = (NSInteger)((double) success * (1 + (double)DILIGENCE * 0.03));
    
    /*
    if (arc4random() % 1000 > success)
        return NO;
     */
    return YES;
}

- (NSArray*) getScoutingPlayerArray
{
    ScoutPosition pos;
    if (SCOUTPOSITION == ScoutAny) {
        NSInteger r = arc4random() % 100;
        if (r < 15) {
            pos = ScoutGoalkeeper;
        } else if (r < 45) {
            pos = ScoutDef;
        } else if (r < 75) {
            pos = ScoutMid;
        } else {
            pos = ScoutAtt;
        }
    } else {
        pos = SCOUTPOSITION;
    }
    
    double valueLimit = 0.0;
    NSInteger ageLimit = [[myGame myData]season] - 42;
    NSInteger finalCut = 27 - JUDGEMENT;
    NSInteger randomCut = finalCut * 2;
    NSInteger firstCut = finalCut * 3;
    NSInteger potentialCut = YOUTH / 2;
    
    
    NSArray* players = [myGame.myData.myTeam getAllPlayersSortByValuation];
    double TopValue = ((Player*) players[0]).Valuation;
    double Top4Value = 0.0;
    for (NSInteger i = 0; i < 4; i ++) {
        Top4Value+= ((Player*) players[i]).Valuation;
    }
    
    if (SCOUTTYPE == StarPlayer) {
        valueLimit = MAX(Top4Value * 2,TopValue * 1.5);
        finalCut = 25 - JUDGEMENT;
        randomCut = finalCut * 1.5;
        firstCut = finalCut * 2;
        potentialCut = 0;
        
    } else if (SCOUTTYPE == SquadPlayer) {
        valueLimit = MAX(Top4Value * 1.65,TopValue * 1.25);
    } else if (SCOUTTYPE == Youth) {
        valueLimit = MAX(Top4Value * .95,TopValue * 0.85);
        ageLimit = [[myGame myData]season] - 25;
        finalCut = 50 - JUDGEMENT/2;
        randomCut = 50;
        firstCut = 200 - YOUTH - JUDGEMENT;
        potentialCut = YOUTH + JUDGEMENT/2;
        
    }
    
    NSMutableArray* resultArray = [NSMutableArray array];
    [resultArray addObject:[self scoutingResultwithFinalCut:finalCut RandomCut:randomCut FirstCut:firstCut PotentialCut:potentialCut ValueLimit:valueLimit Position:pos AgeLimit:ageLimit]];
    return resultArray;
}


- (Player*) scoutingResultwithFinalCut:(NSInteger) finalCut
                             RandomCut:(NSInteger) randomCut
                              FirstCut:(NSInteger) firstCut
                          PotentialCut:(NSInteger) potentialCut
                            ValueLimit:(double) valueLimit
                              Position:(ScoutPosition) pos
                              AgeLimit:(NSInteger) ageLimit
{
    NSString* positionSQL;
    switch (pos) {
        case ScoutAny:
            positionSQL = @"";
            break;
        case ScoutDef:
            positionSQL = @"DEF = 1";
            break;
        case ScoutMid:
            positionSQL = @"(DM = 1 OR MID = 1 OR AM = 1)";
            break;
        case ScoutAtt:
            positionSQL = @"SC = 1";
            break;
        case ScoutGoalkeeper:
            positionSQL = @"GK = 1";
            break;
        default:
            break;
    }
    
    NSString* firstCutSQL = [NSString stringWithFormat:@"SELECT * FROM players WHERE BIRTHYEAR > %i AND VALUATION < %f %@ ORDER BY ABILITY DESC LIMIT %i",ageLimit, valueLimit,positionSQL,firstCut];
    NSString* potentialCutSQL = [NSString stringWithFormat:@"SELECT * FROM (%@) ORDER BY POTENTIAL DESC LIMIT %i",firstCutSQL, potentialCut];
    NSString* randomCutSQL = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM (%@) ORDER BY POTENTIAL LIMIT %i) ORDER BY RANDOM() LIMIT %i",firstCutSQL, firstCut - potentialCut, randomCut - potentialCut];
    NSString* finalCutSQL = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM (%@) UNION SELECT * FROM (%@)) ORDER BY ABILITY DESC LIMIT %i",potentialCutSQL,randomCutSQL,finalCut];
    NSString* finalOneSQL = [NSString stringWithFormat:@"SELECT PLAYERID FROM (%@) ORDER BY RANDOM() LIMIT 1",finalCutSQL];
    NSArray* resultArray = [[myGame myDB]getArrayFromQuery:finalOneSQL];
    return [[GlobalVariableModel myGlobalVariable]getPlayerFromID:[[resultArray[0] objectForKey:@"PLAYERID"]integerValue]];
}

- (void) removeScout
{
    ISACTIVE = NO;
}

- (NSString*) getStringForScoutType:(ScoutTypes)type{
    if (type == SquadPlayer) {
        return @"Squad Player";
    } else if (type == StarPlayer) {
        return @"Star Player";
    } else if (type == Youth) {
        return @"Youth Player";
    } else {
        return nil;
    }
}

- (NSString*) getStringForScoutPosition:(ScoutPosition) pos{
    if (pos == ScoutAny) {
        return @"All Positions";
    } else if (pos == ScoutDef) {
        return @"Defender";
    } else if (pos == ScoutMid) {
        return @"Midfielder";
    } else if (pos == ScoutAtt) {
        return @"Striker";
    } else if (pos == ScoutGoalkeeper) {
        return @"Goalkeeper";
    } else {
        return nil;
    }
}
@end
