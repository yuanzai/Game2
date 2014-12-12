//
//  GlobalVariableModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 01/05/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "GlobalVariableModel.h"
#import "GameModel.h"
#import "Fixture.h"
#import 'C2DArray_double.h'
#import "LineUp.h"
@implementation GlobalVariableModel
{
    NSArray* ageProfile;
    
    NSDictionary* valuationStatListCentre;
    NSDictionary* valuationStatListFlank;
    NSDictionary* valuationStatListGK;
    
    NSDictionary* statBiasTable;
    
    NSDictionary* eventOccurenceFactorTable;
    NSDictionary* standardDeviationTable;
    NSDictionary* tournamentTable;
    NSMutableDictionary* probTables;
    NSMutableDictionary* sGridTables;
    NSArray* attackOutcomeTables;

    NSMutableDictionary* tournamentList;
    NSMutableDictionary* teamList;
    NSMutableDictionary* playerList;
    
    NSMutableDictionary* trainingProfile;
}

+ (id)myGlobalVariable
{
    static GlobalVariableModel *myGlobalVariable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myGlobalVariable = [[self alloc] init];
        [myGlobalVariable setAgeProfile2:nil];
    });
    return myGlobalVariable;
}

- (void) setAgeProfile2:(double*) temp
{
    ageProfile2 = temp;
}

//Fonts
+ (UIFont*) newFont1Small {
    return [UIFont fontWithName:@"8BIT WONDER" size:8.0];
}

+ (UIFont*) newFont1Medium {
    return [UIFont fontWithName:@"8BIT WONDER" size:10.0];
}
+ (UIFont*) newFont1Large {
    return [UIFont fontWithName:@"8BIT WONDER" size:13.0];
}

+ (UIFont*) newFont2Small {
    return [UIFont fontWithName:@"Visitor TT1 BRK" size:12.0];
}

+ (UIFont*) newFont2Medium {
    return [UIFont fontWithName:@"Visitor TT1 BRK" size:18.0];
}

+ (UIFont*) newFont2Large {
    return [UIFont fontWithName:@"Visitor TT1 BRK" size:24.0];
}


# pragma mark STATIC STATS LIST

+ (NSMutableArray*) playerStatList{
    return [[NSMutableArray alloc]initWithObjects:
            @"PAS", @"LPA", @"HEA",  @"SHO", @"TAC", @"AGI", @"CRO",  @"DRI", @"MOV", @"POS",
            @"LSH", @"PEN", @"FRE", @"SPE", @"STR",  @"FIT", @"WOR", @"TEC", @"INT",  @"TEA",nil];
}

+ (NSMutableArray*) gkStatList{
    return [[NSMutableArray alloc]initWithObjects:
            @"DIS", @"HAN", @"AGI", @"REF", @"PHY", @"COM",
            @"POS", @"PEN", @"INT", @"FRE", @"TEC", @"TEA",nil];
}

+ (NSMutableDictionary*) playerGroupStatList {
    NSMutableDictionary* List = [NSMutableDictionary dictionary];
    [List setObject: [[NSMutableArray alloc]initWithObjects:
                      @"PAS", @"LPA", @"CRO", @"MOV", nil] forKey:@"DRILLS"];
    
    [List setObject: [[NSMutableArray alloc]initWithObjects:
                      @"SHO", @"LSH", @"PEN", @"FRE", nil] forKey:@"SHOOTING"];
    
    [List setObject: [[NSMutableArray alloc]initWithObjects:
                      @"POS", @"WOR", @"INT", @"TEA", nil] forKey:@"TACTICS"];
    
    [List setObject: [[NSMutableArray alloc]initWithObjects:
                      @"AGI", @"SPE", @"STR", @"FIT", nil] forKey:@"PHYSICAL"];
    
    [List setObject: [[NSMutableArray alloc]initWithObjects:
                      @"TEC", @"HEA", @"DRI", @"TAC", nil] forKey:@"SKILLS"];
    return List;
}

+ (NSMutableArray*) coachStatList
{
    return [NSMutableArray arrayWithObjects:@"COACHDRILLS", @"COACHPHYSICAL", @"COACHSHOOTING", @"COACHSKILLS", @"COACHTACTICS", @"JUDGEMENT", @"MOTIVATION", nil];
}

+ (NSMutableArray*) scoutStatList
{
    return [NSMutableArray arrayWithObjects:@"JUDGEMENT", @"YOUTH", @"VALUE", @"KNOWLEDGE", @"DILIGENCE", nil];
}

- (NSDictionary*) valuationStatListForFlank:(NSString*) flank;
{
    NSArray* tempArray;
    if ([flank isEqualToString:@"GK"]) {
        if (!valuationStatListGK ){
            valuationStatListGK = [[GameModel myDB]getResultDictionaryForTable:@"valuation" withDictionary:[[NSDictionary alloc]initWithObjectsAndKeys:@"GK",@"FLANKCENTRE", nil]];
        }
        return valuationStatListGK;

    } else if ([flank isEqualToString:@"CENTRE"]) {
        if (!valuationStatListCentre ){
            tempArray = [[GameModel myDB]getArrayFrom:@"valuation" whereData:[[NSDictionary alloc]initWithObjectsAndKeys:@"CENTRE",@"FLANKCENTRE", nil] sortFieldAsc:@""];
            NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionary];
            [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempDictionary setObject:obj forKey:[(NSDictionary*) obj objectForKey:@"POSITION"]];
            }];
            valuationStatListCentre = tempDictionary;
        }
            return valuationStatListCentre;
        
    } else if ([flank isEqualToString:@"FLANK"] ||
               [flank isEqualToString:@"LEFT"] ||
               [flank isEqualToString:@"RIGHT"]) {
        if (!valuationStatListFlank){
            tempArray = [[GameModel myDB]getArrayFrom:@"valuation" whereData:[[NSDictionary alloc]initWithObjectsAndKeys:@"FLANK",@"FLANKCENTRE", nil] sortFieldAsc:@""];
            
            NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionary];
            [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempDictionary setObject:obj forKey:[(NSDictionary*) obj objectForKey:@"POSITION"]];
            }];
            valuationStatListFlank = tempDictionary;
        }
        return valuationStatListFlank;
    }
    return  nil;
}


- (NSDictionary *)standardDeviationTable {
    if (!standardDeviationTable){
        standardDeviationTable = [[GameModel myDB]getStandardDeviationTable];
    }
    return standardDeviationTable;
}

- (NSMutableDictionary*) tournamentList
{
    if (!tournamentList){
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [[[GameModel myDB]getArrayFrom:@"tournaments" withSelectField:@"TOURNAMENTID" whereKeyField:@"" hasKey:@""] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result setObject:[[Tournament alloc]initWithTournamentID:[obj integerValue]] forKey:[NSString stringWithFormat:@"%@",obj]];
        }];
        tournamentList = result;
    }
    return tournamentList;
}

- (NSMutableDictionary*) teamList
{
    if (!teamList){
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [[[GameModel myDB]getArrayFrom:@"teams" withSelectField:@"TEAMID" whereKeyField:@"" hasKey:@""] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result setObject:[[Team alloc]initWithTeamID:[obj integerValue]] forKey:[NSString stringWithFormat:@"%@",obj]];
        }];
        teamList = result;
    }
    return teamList;
}

- (Team*) getTeamFromID:(NSInteger) TEAMID
{
    if (!teamList)
        [self teamList];
    return [teamList objectForKey:[@(TEAMID) stringValue]];
}

- (NSMutableDictionary*) playerList
{
    if (!playerList){
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [[[GameModel myDB]getArrayFrom:@"players" withSelectField:@"PLAYERID" whereKeyField:@"" hasKey:@""] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result setObject:[[Player alloc]initWithPlayerID:[obj integerValue]] forKey:[NSString stringWithFormat:@"%@",obj]];
        }];
        playerList = result;
    }
    return playerList;
}

- (Player*) getPlayerFromID:(NSInteger) PLAYERID
{
    if (!playerList)
        [self playerList];
    return [playerList objectForKey:[@(PLAYERID) stringValue]];
}
# pragma mark Training Methods

- (NSDictionary*) statBiasTable {
    if (!statBiasTable){
        
        NSArray* statBiasList = [[GameModel myDB]getArrayFrom:@"statBias" whereData:nil sortFieldAsc:@""];
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [statBiasList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result setObject:obj forKey:[[obj objectForKey:@"STATBIASID"]stringValue]];
        }];
        statBiasTable = result;
    }
    return statBiasTable ;
}


- (NSArray*) ageProfile
{
    if (!ageProfile){
        NSMutableArray* result = [NSMutableArray array];
        for (NSInteger i =0; i<24; i++) {
            [result addObject:[NSMutableDictionary dictionary]];
        }
        
        NSArray* allProfiles = [[GameModel myDB]getArrayFrom:@"trainingProfile" whereData:nil sortFieldAsc:@""];
        [allProfiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([result objectAtIndex:[[obj objectForKey:@"AGE"]integerValue]]) {
                NSMutableDictionary* profile = [result objectAtIndex:[[obj objectForKey:@"AGE"]integerValue]];
                [profile setObject:obj forKey:[[obj objectForKey:@"PROFILEID"]stringValue]];
            } else {
                NSMutableDictionary* profile = [NSMutableDictionary dictionary];
                [profile setObject:obj forKey:[[obj objectForKey:@"PROFILEID"]stringValue]];
                [result setObject:profile atIndexedSubscript:[[obj objectForKey:@"AGE"]integerValue]];
//                [result setObject:profile forKey:[[obj objectForKey:@"AGE"]stringValue]];
            }
        }];
        ageProfile = result;
        
        //double* testArray[5][5][5];
        //NSMutableArray* newA = [NSMutableArray array];
        //[newA addObject: [NSValue valueWithPointer:testArray]];
        //ageProfile
        
    }
    return ageProfile;
}

- (NSMutableDictionary*) trainingProfile
{
    if (!trainingProfile) {
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        NSArray* allProfiles = [[GameModel myDB]getArrayFrom:@"trainingProfile" whereData:nil sortFieldAsc:@""];
        __block NSInteger maxAge = 0;
        __block NSInteger maxProfileID = 0;
        [allProfiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj objectForKey:@"AGE"]integerValue] > maxAge)
                maxAge = [[obj objectForKey:@"AGE"]integerValue]
            if ([[obj objectForKey:@"PROFILEID"]integerValue] > maxProfileID)
                maxProfileID = [[obj objectForKey:@"AGE"]integerValue]
        }];
        NSDictionary* temp = allProfiles[0];
        
        [[temp allKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            if ([key isEqualToString@"AGE"] || [key isEqualToString@"PROFILEID"])
                return;
                
            C2DArray_double* new2DArray = [C2DArray_double alloc]initWithRows:maxAge Columns:maxProfileID;

            [allProfiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [new2DArray setValue:[[obj objectForKey:@"PROB"]doubleValue] atRow:[[obj objectForKey:@"AGE"]integerValue] Column:[[obj objectForKey:@"PROFILEID"]integerValue]];
            }];
                
            [result setObject:key forKey:new2DArray];
        }];

        trainingProfile = result;
    }
    return trainingProfile;
}

+ (NSArray*) planStats
{
    return [NSArray arrayWithObjects:@"DRILLS",
            @"SHOOTING",
            @"PHYSICAL",
            @"TACTICS",
            @"SKILLS",nil];
    
}

- (NSDictionary*) eventOccurenceFactorTable
{
    if (!eventOccurenceFactorTable)
        eventOccurenceFactorTable = [[GameModel myDB]getEventOccurenceFactorTable];
    return eventOccurenceFactorTable;
}

- (NSDictionary*) getProbResultFromTable:(NSString*) tbl ZoneFlank:(ZoneFlank)zf PositionSide:(PositionSide) ps AttackType:(NSString*) atype DefenseType:(NSString*) dtype isDynamicProb:(BOOL) isProbDy Team:(LineUp*) team PositionSideToExclude:(PositionSide) exPS
{
    if (!probTables)
        probTables = [NSMutableDictionary dictionary];
    
    __block NSMutableArray* resultList = [NSMutableArray array];
    __block NSInteger sumProb = 0;
    __block NSInteger cumuProb = 0;
    __block double prob = (double) (arc4random() % 10000);
    __block NSDictionary* result;
    
    if (![probTables objectForKey:tbl]) {
        NSArray* dataTable = [[GameModel myDB]getArrayFrom:tbl whereData:nil sortFieldAsc:@""];
        [probTables setObject:dataTable forKey:tbl];
    }
    NSArray* enumList = [probTables objectForKey:tbl];
    [enumList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        if (zf.zone != ZoneCount) {
            if (![[obj objectForKey:@"INZONE"] isEqualToString:[Structs getZoneString:zf]])
                return;
            if (![[obj objectForKey:@"INFLANK"] isEqualToString:[Structs getFlankString:zf]])
                return;
        }
        if (ps.position != PositionCount) {
            if (![[obj objectForKey:@"INPOSITION"] isEqualToString:[Structs getPositionString:ps]])
                return;
            if (![[obj objectForKey:@"INSIDE"] isEqualToString:[Structs getSideString:ps]])
                return;
        }
        if (![atype isEqual:@""]) {
            if (![[obj objectForKey:@"INATTACKTYPE"] isEqualToString:atype])
                return;
        }
        if (![dtype isEqual:@""]) {
            if (![[obj objectForKey:@"INDEFENSETYPE"] isEqualToString:dtype])
                return;
            
        }
        
        if (isProbDy) {
            if (team) {
                PositionSide ps = [Structs getPositionSideFromDictionary:obj];
                if (![team.currentTactic hasPlayerAtPositionSide:ps])
                    return;
                if (ps.position == exPS.position && ps.side == exPS.side)
                    return;
            }
            
            sumProb += [[obj objectForKey:@"PROB"]integerValue];
            [resultList addObject:obj];
        } else {
            if ([[obj objectForKey:@"PROB"]integerValue] > prob) {
                result =  obj;
                *stop = YES;
            }
        }
    }];
    
    if (isProbDy) {
        if ([resultList count] ==0)
            [NSException raise:@"table returns 0" format:@"table %@ returns zero count",tbl];
        [resultList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            cumuProb += [[obj objectForKey:@"PROB"]integerValue];
            if ((double)cumuProb/(double)sumProb*10000 > prob){
                result = obj;
                *stop = YES;
            }
        }];
    }
    
    if (!result)
        [NSException raise:@"table returns no result" format:@"table %@ returns no result",tbl];
    
    if (isProbDy && exPS.position != PositionCount)
        if (![team.currentTactic hasPlayerAtPositionSide:[Structs getPositionSideFromDictionary:result]])
            [NSException raise:@"No such PS" format:@"No Such PS %@",result];
        
    return result;
}

- (NSDictionary*) getSGridForType:(NSString*)type Coeff:(NSString*)coeff {
    NSString* key = [NSString stringWithFormat:@"%@%@",type,coeff];
    if (!sGridTables)
        sGridTables = [NSMutableDictionary dictionary];
    
    if (![sGridTables objectForKey:key]) {
        NSDictionary* grid = [[GameModel myDB]getResultDictionaryForTable:@"SGrid" withDictionary:[[NSMutableDictionary alloc]initWithObjectsAndKeys:type,@"TYPE",coeff,@"STATTYPE", nil]];
        if (!grid)
            [NSException raise:@"empty sGrid" format:@"empty SGrid %@",key];
        [sGridTables setObject:grid forKey:key];
    }
    
    
    return [sGridTables objectForKey:key];
}

- (NSInteger) getAttackOutcomesForZoneFlank:(ZoneFlank) zf AttackType:(NSString*) type
{
    if (!attackOutcomeTables)
        attackOutcomeTables = [[GameModel myDB]getArrayFrom:@"AttackOutcome_ZFAtt" whereData:[[NSDictionary alloc]initWithObjectsAndKeys:@"OUTCOME",@"Fail", nil] sortFieldAsc:@""];
    __block double result = 0.0;
    
    [attackOutcomeTables enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        if (zf.zone != ZoneCount) {
            if (![[obj objectForKey:@"INZONE"] isEqualToString:[Structs getZoneString:zf]])
                return;
            if (![[obj objectForKey:@"INFLANK"] isEqualToString:[Structs getFlankString:zf]])
                return;
        }
        if (![[obj objectForKey:@"INATTACKTYPE"] isEqualToString:type])
            return;
        *stop=YES;
        result = [[obj objectForKey:@"PROB"]integerValue];
    }];
    return result;
}

+ (NSArray*) shuffleArray:(NSArray*) arrayInput{
    NSMutableArray* tempArray = [[NSMutableArray alloc]initWithArray:arrayInput];
    for (NSInteger i = 0; i < [tempArray count]; ++i) {
        [tempArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % [tempArray count]];
    }
    return tempArray;
}

@end
