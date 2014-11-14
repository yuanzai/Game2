//
//  Action.m
//  MatchEngine
//
//  Created by Junyuan Lau on 22/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Action.h"

@implementation Action
//ATTACKERS
@synthesize AttackType;
@synthesize FromPositionSide;
@synthesize ToPositionSide;
@synthesize FromZoneFlank;
@synthesize ToZoneFlank;
@synthesize FromPlayer;
@synthesize ToPlayer;

//DEFENDERS
@synthesize DefenseType;
@synthesize OppPositionSide;
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

static double runtime1 =0.0;
static double runtime2 =0.0;
static double runtime3 =0.0;

- (id) init
{
    self = [super init];
    if (self) {
        FromZoneFlank = (ZoneFlank) {ZoneCount,FlankCount};
        ToZoneFlank = (ZoneFlank) {ZoneCount,FlankCount};
        FromPositionSide = (PositionSide) {PositionCount,SideCount};
        ToPositionSide = (PositionSide) {PositionCount,SideCount};
    }; return self;
}

- (void) setActionProperties
{
    actionCount = previousAction.actionCount + 1;
    [self setActionFromPrevious];
    [self setOffense];
    [self setDefense];
    [self getResult];
    [self setCommentary];
    
}

- (void) setActionFromPrevious
{
    //ZONE //FLANK //ATTACKTYPE
    if (!previousAction){
        NSDictionary* record = [GlobalVariableModel getProbResultFromTable:@"ActionStart_ZF" ZoneFlank:ZFNil PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
        
        FromZoneFlank = [Structs getZoneFlankFromDictionary:record];
        AttackType = [record objectForKey:@"OUTATTACKTYPE"];

        if (FromZoneFlank.flank == GKFlank) {
            FromPositionSide.position = GKPosition;
            FromPositionSide.side = GKSide;
            FromPlayer = thisTeam.currentTactic.GoalKeeper;
            
        } else {
            record = [GlobalVariableModel getProbResultFromTable:@"ActionStartPS_PS" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:PSNil];
            FromPositionSide = [Structs getPositionSideFromDictionary:record];
            FromPlayer = [thisTeam.currentTactic getPlayerAtPositionSide:FromPositionSide];
        }
    } else {
        FromZoneFlank = previousAction.ToZoneFlank;
        AttackType = previousAction.NextAttack;
        FromPlayer = previousAction.ToPlayer;
        FromPositionSide = previousAction.ToPositionSide;
    }
    if (!AttackType) {
        [self printAction];
        [NSException raise:@"No AttackType" format:@"No AttackType"];
    }

}

- (void) setOffense 
{

    NSDictionary* record;
    
    if (!AttackType) {
        [self printAction];
        [NSException raise:@"No AttackType" format:@"No AttackType"];
    }
    
    NSDate* date;

    if ([self isSetPiecePenaltyCorner:AttackType])
        [self getSetPieceTakers];
    
    attQuotient = [self getExecutionQualityWithPlayer:FromPlayer ExecutionType:AttackType];

    if (![self isGoalAttempt:AttackType]) {
        
            date = [NSDate date];
        record = [GlobalVariableModel getProbResultFromTable:@"ToZoneFlankZF_ZFAtt" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:AttackType DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
        ToZoneFlank = [Structs getZoneFlankFromDictionary:record];
        [Action addToRuntime:1 amt:-[date timeIntervalSinceNow]];

        date = [NSDate date];

        record = [GlobalVariableModel getProbResultFromTable:@"ToPlayerToZF_PS_dy" ZoneFlank:ToZoneFlank PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:FromPositionSide];
        [Action addToRuntime:2 amt:-[date timeIntervalSinceNow]];
        date = [NSDate date];
        ToPositionSide = [Structs getPositionSideFromDictionary:record];
        [Action addToRuntime:3 amt:-[date timeIntervalSinceNow]];
        

        ToPlayer = [thisTeam.currentTactic getPlayerAtPositionSide:ToPositionSide];


        record = [GlobalVariableModel getProbResultFromTable:@"NextAttackType_ZFAtt" ZoneFlank:ToZoneFlank PositionSide:PSNil AttackType:AttackType DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
        NextAttack = [record objectForKey:@"OUTATTACKTYPE"];

    }

}

- (void) setDefense 
{

    NSDictionary* record;
    OppKeeper = oppTeam.currentTactic.GoalKeeper;
    
    if ([AttackType isEqualToString:@"FreekickShortPass"]||
        [AttackType isEqualToString:@"FreekickLongPass"]||
        [AttackType isEqualToString:@"FreekickCross"]) {
        DefenseType = AttackType;
    } else if (!([self isSetPieceShot:AttackType] || FromZoneFlank.zone == GK)) {
        
        record = [GlobalVariableModel getProbResultFromTable:@"DefenseType_ZFAtt_dy" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:AttackType DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:PSNil];
        DefenseType = [record objectForKey:@"OUTDEFENSETYPE"];
        
        record = [GlobalVariableModel getProbResultFromTable:@"OppPlayerPS_PS_dy" ZoneFlank:ZFNil PositionSide:FromPositionSide AttackType:@"" DefenseType:@"" isDynamicProb:YES Team:oppTeam PositionSideToExclude:PSNil];
        OppPositionSide = [Structs getPositionSideFromDictionary:record];
        OppPlayer = [oppTeam.currentTactic getPlayerAtPositionSide:OppPositionSide];
        
        if ([DefenseType isEqualToString:@"Caught"])
            OppPlayer = OppKeeper;
        
    } else {
        DefenseType = @"Save";
        OppPlayer = OppKeeper;
    }
    if (!DefenseType) {
        [NSException raise:@"No DefenseType" format:@"No DefenseType"];
        [self printAction];
    }
    defQuotient = [self getExecutionQualityWithPlayer:OppPlayer ExecutionType:DefenseType];
}

- (double) getExecutionQualityWithPlayer:(Player*) thisPlayer ExecutionType:(NSString*) type
{

    __block double CoEffQ;
    __block double TopQ;
    __block double StatQ;
    
    NSDictionary* statGrid = [GlobalVariableModel getSGridForType:type Coeff:@"COEFF"];
    NSDictionary* topStatGrid = [GlobalVariableModel getSGridForType:type Coeff:@"TOP"];;
    
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
    
    return (  (80 - QDistRandom) * (
                                    ((80 - TopQDistRandom) * CoEffQ
                                    +(20 + TopQDistRandom) * TopQ)
                                    /100)
            + (20 + QDistRandom) * StatQ)/100 * thisPlayer.Condition;
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
    NSDictionary* record = [[DatabaseModel myDB]getResultDictionaryForTable:@"Offside_ZZAtt" withDictionary:[[NSDictionary alloc]initWithObjectsAndKeys:@"INZONE",[Structs getZoneString:fromZF],@"OUTZONE",[Structs getZoneString:toZF],@"INATTACKTYPE",type, nil]];
    if (record) {
        if ([[record objectForKey:@"PROB"]integerValue] > (arc4random() % 10000))
            return YES;
    }
    return NO;
}

- (void) getFoulResult {
    
    NSDictionary* record = [[DatabaseModel myDB]getResultDictionaryForTable:@"FoulGrid" withDictionary:
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
        record = [GlobalVariableModel getProbResultFromTable:@"NextAttackType_ZFAtt" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"FoulDef" DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
        NextAttack = [record objectForKey:@"OUTATTACKTYPE"];
        ToZoneFlank = FromZoneFlank;
        
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
        if (!NextAttack)
            [NSException raise:@"No Next Attack after foul" format:@"No Next Attack after foul"];
        return;
    }
    
    record = [[DatabaseModel myDB]getResultDictionaryForTable:@"FoulGrid" withDictionary:
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
        
        NSDictionary* record = [GlobalVariableModel getProbResultFromTable:@"FreeKickPlayerPS_ZF_dy" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:YES Team:thisTeam PositionSideToExclude:PSNil];
        
        FromPositionSide =[Structs getPositionSideFromTextWithPosition:[record objectForKey:@"OUTPOSITION"] Side:[record objectForKey:@"OUTSIDE"]];
        FromPlayer = [thisTeam.currentTactic getPlayerAtPositionSide:FromPositionSide];
    }
}

- (Player*) getTopPlayerFromArray:(NSArray*) data InStat1:(NSString*) stat1 Stat2:(NSString*) stat2
{
    NSArray *sorted = [data sortedArrayUsingComparator:^NSComparisonResult(Player* obj1, Player* obj2) {
        double a = [[obj1.Stats objectForKey:stat1]doubleValue];
        if (![stat2 isEqualToString:@""]) {
            a *=100;
            a +=[[obj1.Stats objectForKey:stat2]doubleValue];
        }
        double b = [[obj2.Stats objectForKey:stat1]doubleValue];
        if (![stat2 isEqualToString:@""]) {
            b *=100;
            b +=[[obj2.Stats objectForKey:stat2]doubleValue];
        }
        
        if (a < b) {
            return NSOrderedAscending;
        } else if (a > b) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return [sorted objectAtIndex:[sorted count]-1];
}


- (BOOL) isGoalAttempt:(NSString*) type
{
    return ([type isEqualToString:@"HeaderShot"]||
            [type isEqualToString:@"LongShot"]||
            [type isEqualToString:@"Shot"]||
            [type isEqualToString:@"FreekickLongShot"]||
            [type isEqualToString:@"FreekickShot"]||
            [type isEqualToString:@"Penalty"]);
}

- (BOOL) isSetPiecePenaltyCorner:(NSString*) type {
    return ([type isEqualToString:@"FreekickShortPass"]||
            [type isEqualToString:@"FreekickShortLong"]||
            [type isEqualToString:@"FreekickCross"]||
            [type isEqualToString:@"FreekickShot"]||
            [type isEqualToString:@"FreekickLongShot"]||
            [type isEqualToString:@"Corner"]||
            [type isEqualToString:@"Penalty"]);
}

- (BOOL) isSetPieceShot:(NSString*) type {
    return ([type isEqualToString:@"FreekickShot"]||
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
    
    if ([AttackType isEqualToString:@"FreekickLongPass"] ||
        [AttackType isEqualToString:@"FreekickShortPass"] ||
        [AttackType isEqualToString:@"FreekickCross"]) {
        
        NSString* freekickAttack = [AttackType stringByReplacingOccurrencesOfString:@"Freekick" withString:@""];
        NSInteger prob = [GlobalVariableModel getAttackOutcomesForZoneFlank:FromZoneFlank AttackType:freekickAttack];
        
        if (prob > (arc4random() % 10000)) {
            result = Fail;
        } else {
            result = Success;
        }
    } else {
        
        NSInteger prob = [GlobalVariableModel getAttackOutcomesForZoneFlank:FromZoneFlank AttackType:AttackType];
        
        if (prob > (arc4random() % 10000)) {
            record = [GlobalVariableModel getProbResultFromTable:@"FailOut_ZF" ZoneFlank:FromZoneFlank PositionSide:PSNil AttackType:@"" DefenseType:@"" isDynamicProb:NO Team:thisTeam PositionSideToExclude:PSNil];
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
}

- (void) printAction
{
    @try {
        NSLog(@"Attack - %@", self.AttackType);
        NSLog(@"Next Attack - %@", self.NextAttack);
        NSLog(@"Defense - %@", self.DefenseType);
        NSLog(@"From ZF - %@,%@", [Structs getZoneString:FromZoneFlank], [Structs getFlankString:FromZoneFlank]);
        NSLog(@"To ZF - %@,%@", [Structs getZoneString:ToZoneFlank], [Structs getFlankString:ToZoneFlank]);
        NSLog(@"AttQ %f, DefQ %f", attQuotient, defQuotient);
        NSLog(@"Fail prob %f", ((defQuotient - attQuotient)*.08 + .6) *10000);

        if (previousAction)  {
            NSLog(@"p.Attack - %@", previousAction.AttackType);
            NSLog(@"p.Next Attack - %@", previousAction.NextAttack);
            NSLog(@"p.Defense - %@", previousAction.DefenseType);
            NSLog(@"p.Result - %i", previousAction.result);
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    //NSLog(@"From ZF - %@", thisAction.FromZoneFlank);
    //NSLog(@"To ZF - %@", thisAction.ToZoneFlank);
}

+ (double) addToRuntime:(int)no amt:(double) amt{
    if (no==1) {
        runtime1 +=amt;
        return runtime1;
    }else if (no==2) {
        runtime2 +=amt;
        return runtime2;
        
    }else if (no==3){
        runtime3 +=amt;
        return runtime3;
    }
    return 0.0;
}
@end
