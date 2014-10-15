//
//  Action.m
//  MatchEngine
//
//  Created by Junyuan Lau on 22/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Action.h"
#import "GlobalVariableModel.h"
#import "DatabaseModel.h"

@implementation Action
//ATTACKERS
@synthesize AttackType;
@synthesize FromPositionSide;
@synthesize ToPositionSide;
@synthesize FromZoneFlank;
@synthesize ToZoneFlank;
@synthesize OppPositionSide;
@synthesize FromPlayer;
@synthesize ToPlayer;

//DEFENDERS
@synthesize DefenseType;
@synthesize OppPlayer;
@synthesize OppKeeper;

@synthesize thisTeam;
@synthesize oppTeam;

@synthesize NextAttack;
@synthesize result;
@synthesize injuredPlayer;
@synthesize Commentary;
@synthesize attQuotient;
@synthesize defQuotient;

@synthesize previousAction;
@synthesize actionCount;

const ZoneFlank ZFNil = {ZoneCount, FlankCount};
const PositionSide PSNil = {PositionCount, SideCount};


- (void) setActionProperties
{
    NSDictionary* record;
    
    actionCount = previousAction.actionCount + 1;
    [self setActionFromPrevious];
    
    if ([self isSetPiecePenaltyCorner:AttackType])
        [self getSetPieceTakers];
    
    attQuotient = [self getExecutionQualityWithPlayer:FromPlayer ExecutionType:AttackType];
    
    record = [self getProbResultFromTable:@"ToZoneFlankZF_ZFAtt" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:AttackType DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
    ToZoneFlank = [self getZoneFlankFromDictionary:record];
    
    record = [self getProbResultFromTable:@"ToPlayerToZF_PS_dy" ZoneFlank:ToZoneFlank PositionSide:PSNil AttackType:AttackType DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:FromPositionSide];
    ToPositionSide = [self getPositionSideFromDictionary:record];
    ToPlayer = (MatchPlayer*) [thisTeam.currentTactic getPlayerAtPositionSide:ToPositionSide];
    
    OppKeeper = (MatchPlayer*) oppTeam.currentTactic.GoalKeeper;
    
    if (![self isSetPiecePenaltyCorner:AttackType]) {

        record = [self getProbResultFromTable:@"DefenseType_ZFAtt_dy" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:AttackType DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:PSNil];
        
        DefenseType = [record objectForKey:@"OUTDEFENSETYPE"];
        record = [self getProbResultFromTable:@"OppPlayerPS_PS_dy" ZoneFlank:ZFNil PositionSide:FromPositionSide AttackType:@"" DefenseType:@"" isDynamicProb:YES Team:oppTeam PositionSideToExclude:PSNil];
        OppPositionSide = [self getPositionSideFromDictionary:record];
        
        OppPlayer = (MatchPlayer*) [oppTeam.currentTactic getPlayerAtPositionSide:OppPositionSide];
        
        if ([DefenseType isEqualToString:@"Caught"])
            OppPlayer = OppKeeper;
        defQuotient = [self getExecutionQualityWithPlayer:OppPlayer ExecutionType:DefenseType];
    }
    
    record = [self getProbResultFromTable:@"NextAttackType_ZFAtt" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:AttackType DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
    
    NextAttack = [record objectForKey:@"OUTATTACKTYPE"];
    [self getResult];
    [self setCommentary];
    
}

- (void) setActionFromPrevious
{
    //ZONE //FLANK //ATTACKTYPE
    if (!previousAction){
        NSDictionary* record = [self getProbResultFromTable:@"ActionStart_ZF" ZoneFlank:ZFNil PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
        
        FromZoneFlank = [self getZoneFlankFromDictionary:record];
        AttackType = [record objectForKey:@"OUTATTACKTYPE"];

        if (FromZoneFlank.flank == GKFlank) {
            FromPositionSide.position = GKPosition;
            FromPositionSide.side = GKSide;
            FromPlayer = (MatchPlayer*) thisTeam.currentTactic.GoalKeeper;
            
        } else {
            record = [self getProbResultFromTable:@"ActionStartPS_PS_dy" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:PSNil];
            FromPositionSide = [self getPositionSideFromDictionary:record];
            FromPlayer = (MatchPlayer*) [thisTeam.currentTactic getPlayerAtPositionSide:FromPositionSide];
        }
    } else {
        FromZoneFlank = previousAction.ToZoneFlank;
        AttackType = previousAction.NextAttack;
        FromPlayer = previousAction.ToPlayer;
        FromPositionSide = previousAction.ToPositionSide;
    }
}

- (double) getExecutionQualityWithPlayer:(MatchPlayer*) thisPlayer ExecutionType:(NSString*) type
{

    __block double CoEffQ;
    __block double TopQ;
    __block double StatQ;
    
    NSDictionary* statGrid = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"SGrid" withDictionary:[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"TYPE",type,@"STATTYPE",@"COEFF", nil]];
    
    NSDictionary* topStatGrid = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"TOP" withDictionary:[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"TYPE",type,@"STATTYPE",@"COEFF", nil]];
    
    __block int topStatRandom = arc4random() % 6;
    
    [thisPlayer.matchStats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        CoEffQ += [obj doubleValue] * [[statGrid objectForKey:key]doubleValue];
        StatQ += [obj doubleValue];
        if ([[topStatGrid objectForKey:key]integerValue]==1) {
            if (topStatRandom==0) {
                TopQ = [obj doubleValue];
            } else {
                topStatRandom--;
            }
        }
    }];
    
    CoEffQ *= thisPlayer.PosCoeff;
    StatQ /= [thisPlayer.matchStats count];
    
    double QDistRandom = arc4random() % 15;
    double TopQDistRandom = arc4random() % 10;
    
    return ((80 - QDistRandom) * (((80 - TopQDistRandom) * CoEffQ +  (80 + TopQDistRandom) * TopQ)/100) + (20 + QDistRandom) * StatQ) * thisPlayer.Condition;
}

- (void) getResult;
{
    if ([self isOffSideWithFromZone:FromZoneFlank ToZone:ToZoneFlank AttackType:AttackType])
        result = Offside;
    
    if ([self isGoalAttempt:AttackType]){
        [self getGoalAttemptResult];
    } else {
        [self getNonGoalAttemptResult];
    }
    
    if (!(result == Goal || result == Save || result == OffTarget))
        [self getFoulResult];
    
    [self getInjury];
}

- (BOOL) isOffSideWithFromZone:(ZoneFlank) fromZF ToZone:(ZoneFlank) toZF AttackType: (NSString*) type
{
    NSDictionary* record = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"Offside_ZZAtt" withDictionary:[[NSDictionary alloc]initWithObjectsAndKeys:@"INZONE",[self getZoneString:fromZF],@"OUTZONE",[self getZoneString:toZF],@"INATTACKTYPE",type, nil]];
    if (record) {
        if ([[record objectForKey:@"PROB"]integerValue] > (arc4random() % 10000))
            return YES;
    }
    return NO;
}

- (void) getFoulResult {
    
    NSDictionary* record = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"FoulGrid" withDictionary:
                            [[NSDictionary alloc]initWithObjectsAndKeys:
                             @"DEF", @"FOULSIDE",
                             AttackType, @"ATTACKTYPE",
                             DefenseType, @"DEFENSETYPE", nil]];
    
    double foulProb = [[record objectForKey:@"FOULPROB"]doubleValue]*10000;
    double yellowProb = [[record objectForKey:@"YELLOWPROB"]doubleValue]*10000;
    double redProb = [[record objectForKey:@"REDPROB"]doubleValue]*10000;
    double areaCentreCoeff = [[record objectForKey:@"AREACENTRECOEFF"]doubleValue]*10000;
    if (FromZoneFlank.zone == Area && FromZoneFlank.flank == CentreFlank) {
        foulProb *= areaCentreCoeff;
    }
    
    if (arc4random()%10000 < foulProb) {
        record = [self getProbResultFromTable:@"NextAttackType_ZFAtt" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"FoulDef" DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
        NextAttack = [record objectForKey:@"OUTATTACKTYPE"];
        
        if (arc4random()%10000 < yellowProb) {
            
            if (OppPlayer.yellow) {
                OppPlayer.red = YES;
                result = DefenseRed;
            } else {
                OppPlayer.yellow = YES;
                result = DefenseYellow;
            }
        } else if (arc4random()%10000 < redProb) {
            OppPlayer.red = YES;
            result = DefenseRed;
        }
        else {
            result = DefenseFoul;
        }
        return;
    }
    
    record = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"FoulGrid" withDictionary:
              [[NSDictionary alloc]initWithObjectsAndKeys:
               @"ATT", @"FOULSIDE",
               AttackType, @"ATTACKTYPE",
               DefenseType, @"DEFENSETYPE", nil]];
    
    foulProb = [[record objectForKey:@"FOULPROB"]doubleValue]*10000;
    yellowProb = [[record objectForKey:@"YELLOWPROB"]doubleValue]*10000;
    redProb = [[record objectForKey:@"REDPROB"]doubleValue]*10000;
    
    if (arc4random()%10000 < foulProb) {
        if (arc4random()%10000 < yellowProb) {
            if (FromPlayer.yellow) {
                FromPlayer.red = YES;
                result = AttackRed;
            } else {
                FromPlayer.yellow = YES;
                result = AttackYellow;
            }
        } else if (arc4random()%10000 < redProb) {
            FromPlayer.red = YES;
            result = AttackRed;
        }
        else {
            result = AttackFoul;
        }
    }
}

- (void) getSetPieceTakers {
    NSArray* outFieldPlayers = [thisTeam.currentTactic getOutFieldPlayers];
    if ([AttackType isEqualToString:@"FreekickShot"]) {
        FromPlayer = [self getTopPlayerFromArray:outFieldPlayers InStat1:@"FRE" Stat2:@"SHO"];
    } else if ([AttackType isEqualToString:@"FreekickLongShot"]) {
        FromPlayer = [self getTopPlayerFromArray:outFieldPlayers InStat1:@"FRE" Stat2:@"LSH"];
    } else if ([AttackType isEqualToString:@"FreekickCross"] || [AttackType isEqualToString:@"Corner"]) {
        FromPlayer = [self getTopPlayerFromArray:outFieldPlayers InStat1:@"FRE" Stat2:@"CRO"];
    } else if ([AttackType isEqualToString:@"Penalty"]) {
        FromPlayer = [self getTopPlayerFromArray:outFieldPlayers InStat1:@"PEN" Stat2:@"SHO"];
        OppPlayer = OppKeeper;
    } else {
        NSDictionary* record = [self getProbResultFromTable:@"FreeKickPlayerPS_ZF_dy" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:PSNil];
        
        FromPositionSide =[self getPositionSideFromTextWithPosition:[record objectForKey:@"OUTPOSITION"] Side:[record objectForKey:@"OUTSIDE"]];
        FromPlayer = (MatchPlayer*) [thisTeam.currentTactic getPlayerAtPositionSide:FromPositionSide];
    }
}

- (MatchPlayer*) getTopPlayerFromArray:(NSArray*) data InStat1:(NSString*) stat1 Stat2:(NSString*) stat2
{
    NSArray *sorted = [data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        double a = [[((MatchPlayer*) obj1).Stats objectForKey:stat1]doubleValue];
        if (![stat2 isEqualToString:@""]) {
            a *=100;
            a +=[[((MatchPlayer*) obj1).Stats objectForKey:stat2]doubleValue];
        }
        double b = [[((MatchPlayer*) obj2).Stats objectForKey:stat1]doubleValue];
        if (![stat2 isEqualToString:@""]) {
            b *=100;
            b +=[[((MatchPlayer*) obj2).Stats objectForKey:stat2]doubleValue];
        }
        
        if (a < b) {
            return NSOrderedAscending;
        } else if (a > b) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return [sorted objectAtIndex:[sorted count]];
}


- (BOOL) isGoalAttempt:(NSString*) type
{
    return ([AttackType isEqualToString:@"HeaderShot"]||
            [AttackType isEqualToString:@"LongShot"]||
            [AttackType isEqualToString:@"Shot"]||
            [AttackType isEqualToString:@"FreekickLongShot"]||
            [AttackType isEqualToString:@"FreekickShot"]);
}

- (BOOL) isSetPiecePenaltyCorner:(NSString*) type {
    return ([type isEqualToString:@"FreekickShortPass"]||
            [type isEqualToString:@"FreekickShortLong"]||
            [type isEqualToString:@"FreekickCross"]||
            [type isEqualToString:@"FreekickShot"]||
            [type isEqualToString:@"FreekickLongShot"]||
            [type isEqualToString:@"Penalty"]);
}

- (void) getGoalAttemptResult
{
    double onTarget = attQuotient;
    int r = arc4random() % 20;
    if (previousAction)
        onTarget = previousAction.attQuotient * (10+r)/100 + attQuotient * (90-r)/100;
    
    if (arc4random() % 10000 < ((onTarget/30)*10000)){
        result = OffTarget;
    } else {
        
        if (arc4random() % 10000 < ((defQuotient - attQuotient)*.08 + .6) *10000) {
            result = Fail; // Successfully defended by OppPlayer
            
            // If fail then GK Defense
        } else {
            if ([DefenseType isEqualToString:@"Save"]){
                
                double gkDef = [self getExecutionQualityWithPlayer:OppKeeper ExecutionType:@"Save"];
                
                if (arc4random() % 10000 < ((gkDef - attQuotient)*.05 + .6) *10000) {
                    result = Save;
                    
                } else {
                    result = Goal;
                }
            } else {
               result = Fail;
            }
        }
    }
}

- (void) getNonGoalAttemptResult
{
    NSDictionary* record;
    record = [[[DatabaseModel alloc]init]getResultDictionaryForTable:@"AttackOutcome_ZFAtt" withDictionary:[[NSDictionary alloc]initWithObjectsAndKeys:@"INZONE",[self getZoneString:FromZoneFlank],@"INFLANK",[self getFlankString:FromZoneFlank],@"INATTACKTYPE",AttackType, nil]];
    NSInteger prob = 0;
    if (record)
        prob = [[record objectForKey:@"PROB"]integerValue];
        
    if (prob > (arc4random() % 10000)) {
        record = [self getProbResultFromTable:@"FailOut_ZF" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
        NSString* recordOutcome = [record objectForKey:@"OUTCORNER"];
        
        //result = ThrowIn;
        //Out disabled - assumed to be fail
        if ([recordOutcome isEqualToString:@"Corner"]) {
            result = Corner;
        } else if (arc4random() % 10000 < (attQuotient / (defQuotient + attQuotient) * 10000)) {
            result = Fail;
        } else {
            result = Success;
        }
    } else {
        result = Success;
    }
}

- (void) getInjury
{
    if (result == DefenseFoul) {
        if (arc4random() % 10000 < 60)
            injuredPlayer = FromPlayer;
    } else if (result == DefenseYellow || result == DefenseRed) {
        if (arc4random() % 10000 < 500)
            injuredPlayer = FromPlayer;
    } else if (result == AttackFoul) {
        if (arc4random() % 10000 < 40)
            injuredPlayer = OppPlayer;
    } else if (result == AttackYellow || result == AttackRed) {
        if (arc4random() % 10000 < 60)
            injuredPlayer = OppPlayer;
    } else if ([DefenseType isEqualToString:@"SlidingTackle"]) {
        if (arc4random() % 10000 < 80)
            injuredPlayer = FromPlayer;
    } else if ([DefenseType isEqualToString:@"Tackle"]) {
        if (arc4random() % 10000 < 50)
            injuredPlayer = FromPlayer;
    } else {
        if (arc4random() % 10000 < 30) {
            injuredPlayer = FromPlayer;
        } else if (arc4random() % 10000 < 30) {
            injuredPlayer = OppPlayer;
        }
    }
}

- (PositionSide) getPositionSideFromDictionary:(NSDictionary*) record
{
    return [self getPositionSideFromTextWithPosition:[record objectForKey:@"OUTPOSITION"] Side:[record objectForKey:@"OUTSIDE"]];
}

- (ZoneFlank) getZoneFlankFromDictionary:(NSDictionary*) record
{
    return [self getZoneFlankFromTextWithZone:[record objectForKey:@"OUTZONE"] Flank:[record objectForKey:@"OUTFLANK"]];
}

- (NSDictionary*) getProbResultFromTable:(NSString*) tbl ZoneFlank:(ZoneFlank)zf PositionSide:(PositionSide) ps AttackType:(NSString*) atype DefenseType:(NSString*) dtype isDynamicProb:(BOOL) isProbDy Team:(LineUp*) team PositionSideToExclude:(PositionSide) exPS
{
    NSMutableDictionary* whereData = [[NSMutableDictionary alloc]init];
    
    [whereData setObject:[self getZoneString:zf] forKey:@"INZONE"];
    [whereData setObject:[self getFlankString:zf] forKey:@"INFLANK"];
    [whereData setObject:[self getPositionString:ps] forKey:@"INPOSITION"];
    [whereData setObject:[self getSideString:ps] forKey:@"INSIDE"];
    [whereData setObject:atype forKey:@"INATTACKTYPE"];
    [whereData setObject:dtype forKey:@"INDEFENSETYPE"];
    NSArray* data = [[[DatabaseModel alloc]init]getArrayFrom:tbl whereData:whereData sortFieldAsc:@"PROB"];
    
    return [self getProbDictionaryRecordWithArray:data isProbDy:isProbDy Team:team PositionSideToExclude:exPS];
}

- (PositionSide) getPositionSideFromTextWithPosition:(NSString*)position Side:(NSString*) side
{
    PositionSide retPositionSide;
    
    if ([[position uppercaseString] caseInsensitiveCompare:@"DEF"]) {
        retPositionSide.position = Def;
    } else if (([[position uppercaseString] caseInsensitiveCompare:@"DM"])) {
        retPositionSide.position = DM;
    } else if ([[position uppercaseString] caseInsensitiveCompare:@"MID"]) {
        retPositionSide.position  = Mid;
    } else if ([[position uppercaseString] caseInsensitiveCompare:@"AM"]) {
        retPositionSide.position  = AM;
    } else if ([[position uppercaseString] caseInsensitiveCompare:@"SC"]) {
        retPositionSide.position  = SC;
    } else if ([[position uppercaseString] caseInsensitiveCompare:@"GK"]) {
        retPositionSide.position  = GKPosition;
    }
    
    if ([[side uppercaseString] caseInsensitiveCompare:@"LEFT"]) {
        retPositionSide.side = Left;
    } else if (([[side uppercaseString] caseInsensitiveCompare:@"LEFTCENTRE"])) {
        retPositionSide.side = LeftCentre;
    } else if ([[side uppercaseString] caseInsensitiveCompare:@"CENTRE"]) {
        retPositionSide.side = Centre;
    } else if ([[side uppercaseString] caseInsensitiveCompare:@"RIGHTCENTRE"]) {
        retPositionSide.side = RightCentre;
    } else if ([[side uppercaseString] caseInsensitiveCompare:@"RIGHT"]) {
        retPositionSide.side = Right;
    } else if ([[side uppercaseString] caseInsensitiveCompare:@"GK"]) {
        retPositionSide.side = GKSide;
    }
    return retPositionSide;
}

- (ZoneFlank) getZoneFlankFromTextWithZone:(NSString*)zone Flank:(NSString*) flank
{
    ZoneFlank retZoneFlank;
    if ([[zone uppercaseString] caseInsensitiveCompare:@"LEFT"]) {
        retZoneFlank.flank = LeftFlank;
    } else if (([[zone uppercaseString] caseInsensitiveCompare:@"CENTRE"])) {
        retZoneFlank.flank = CentreFlank;
    } else if ([[zone uppercaseString] caseInsensitiveCompare:@"RIGHT"]) {
        retZoneFlank.flank = RightFlank;
    } else if ([[zone uppercaseString] caseInsensitiveCompare:@"GK"]) {
        retZoneFlank.flank = GKFlank;
    }
    
    if ([[flank uppercaseString] caseInsensitiveCompare:@"OWN"]) {
        retZoneFlank.zone = Own;
    } else if (([[flank uppercaseString] caseInsensitiveCompare:@"OPP"])) {
        retZoneFlank.zone = Opp;
    } else if ([[flank uppercaseString] caseInsensitiveCompare:@"AREA"]) {
        retZoneFlank.zone = Area;
    } else if ([[flank uppercaseString] caseInsensitiveCompare:@"GK"]) {
        retZoneFlank.zone = GK;
    }
    return retZoneFlank;
}

- (NSString*) getZoneString:(ZoneFlank) zf
{
    if (zf.zone == Own)
        return @"Own";
    if (zf.zone == Opp)
        return @"Opp";
    if (zf.zone == Area)
        return @"Area";
    if (zf.zone == GK)
        return @"GK";
    return @"";
}

- (NSString*) getFlankString:(ZoneFlank) zf
{
    if (zf.flank == LeftFlank)
        return @"Left";
    if (zf.flank == CentreFlank)
        return @"Centre";
    if (zf.flank == RightFlank)
        return @"Right";
    if (zf.flank == GKFlank)
        return @"GK";
    return @"";
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
    return @"";
}

- (NSString*) getSideString:(PositionSide) ps
{
    if (ps.side == Left)
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
    return @"";
}

- (void) setCommentary
{
    if (result == Success){
        Commentary = [NSString stringWithFormat:@"%@ from %@",AttackType,FromPlayer.DisplayName];
    } else if (result == Fail) {
        Commentary = [NSString stringWithFormat:@"FAILED %@ from %@",AttackType,FromPlayer.DisplayName];
    } else if (result == Save) {
        Commentary = [NSString stringWithFormat:@"%@ from %@\nSAVE By %@",AttackType,FromPlayer.DisplayName,OppKeeper.DisplayName];
    } else if (result == Goal) {
        Commentary = [NSString stringWithFormat:@"%@ Scores",FromPlayer.DisplayName];
    } else if (result == OffTarget) {
        Commentary = [NSString stringWithFormat:@"%@ from %@ OFF TARGET",AttackType,FromPlayer.DisplayName];
    } else if (result == DefenseRed) {
        Commentary = [NSString stringWithFormat:@"%@ Gets Red Card for %@ on %@",OppPlayer.DisplayName,DefenseType,FromPlayer.DisplayName];
    } else if (result == DefenseYellow) {
        Commentary = [NSString stringWithFormat:@"%@ Gets Yellow Card for %@ on %@",OppPlayer.DisplayName,DefenseType,FromPlayer.DisplayName];
    } else if (result == DefenseFoul) {
        Commentary = [NSString stringWithFormat:@"%@ Fouls %@ on %@",OppPlayer.DisplayName,DefenseType,FromPlayer.DisplayName];
    } else {
        Commentary = [NSString stringWithFormat:@"%@ from %@\n%@ from Player %@",AttackType,FromPlayer.DisplayName,DefenseType,OppPlayer.DisplayName];
    }
    NSLog(@"%@",Commentary);
}


- (NSDictionary*) getProbDictionaryRecordWithArray:(NSArray*) data isProbDy:(BOOL) isProbDy Team:(LineUp*) team PositionSideToExclude:(PositionSide) exPS
{
    
    NSMutableArray* dataNew;
    __block NSDictionary* retDict;
    double prob = (double) (arc4random() % 10000);
    __block double sumProb = 0;
    
    if (isProbDy) {
        dataNew  =[[NSMutableArray alloc]init];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PositionSide ps = [self getPositionSideFromTextWithPosition:[obj objectForKey:@"POSITION"] Side:[obj objectForKey:@"SIDE"]];
            if ([team.currentTactic hasPlayerAtPositionSide:ps] && ![team.currentTactic hasPlayerAtPositionSide:exPS]) {
                sumProb += [[obj objectForKey:@"PROB"]doubleValue];
                [dataNew addObject:obj];
            }
        }];
    } else {
        dataNew = [[NSMutableArray alloc]initWithArray:data];
        sumProb = 10000;
    }
    
    
    [dataNew enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (([[obj objectForKey:@"PROB"]doubleValue]/sumProb * 10000) > prob){
            retDict = (NSDictionary*) obj;
            *stop = YES;
        }
    }];
    return retDict;
}

@end
