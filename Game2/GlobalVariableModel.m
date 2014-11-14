//
//  GlobalVariableModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 01/05/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "GlobalVariableModel.h"
#import "DatabaseModel.h"
#import "Fixture.h"

#import "LineUp.h"
@implementation GlobalVariableModel

@synthesize playerStatList,gkStatList, allStatList,eventOccurenceFactorTable, playerGroupStatList, standardDeviationTable, valuationStatListCentre, valuationStatListFlank, tournamentTable,probTables,sGridTables ;

static GlobalVariableModel* myGlobalVariableModel;

+ (GlobalVariableModel*)myGlobalVariableModel
{
    if (!myGlobalVariableModel) {
        myGlobalVariableModel = [[GlobalVariableModel alloc] init];
        [myGlobalVariableModel setAllStatList];
        [myGlobalVariableModel setEventOccurenceFactorTableFromDB];
    }
    return myGlobalVariableModel;
}


/*
+ (id)myGlobalVariableModel {
    static GlobalVariableModel *myGlobalVariableModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myGlobalVariableModel = [[self alloc] init];
        [myGlobalVariableModel setAllStatList];
        [myGlobalVariableModel setEventOccurenceFactorTableFromDB];

    });
    
    return myGlobalVariableModel;
}
*/
+ (NSDictionary*) valuationStatListForFlank:(NSString*) flank;
{
    NSArray* tempArray;
    if ([flank isEqualToString:@"GK"]) {
        if (!myGlobalVariableModel.valuationStatListGK ){
            NSDictionary* tempDictionary = [[DatabaseModel myDB]getResultDictionaryForTable:@"valuation" withDictionary:[[NSDictionary alloc]initWithObjectsAndKeys:@"GK",@"FLANKCENTRE", nil]];
            [[GlobalVariableModel myGlobalVariableModel] setValuationStatListGK:tempDictionary];
        }
        return myGlobalVariableModel.valuationStatListGK;

    } else if ([flank isEqualToString:@"CENTRE"]) {
        if (!myGlobalVariableModel.valuationStatListCentre ){
            tempArray = [[DatabaseModel myDB]getArrayFrom:@"valuation" whereData:[[NSDictionary alloc]initWithObjectsAndKeys:@"CENTRE",@"FLANKCENTRE", nil] sortFieldAsc:@""];
            NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionary];
            [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempDictionary setObject:obj forKey:[(NSDictionary*) obj objectForKey:@"POSITION"]];
            }];
            [[GlobalVariableModel myGlobalVariableModel] setValuationStatListCentre:tempDictionary];
        }
            return myGlobalVariableModel.valuationStatListCentre;
        
    } else if ([flank isEqualToString:@"FLANK"] ||
               [flank isEqualToString:@"LEFT"] ||
               [flank isEqualToString:@"RIGHT"]) {
        if (!myGlobalVariableModel.valuationStatListFlank){
            tempArray = [[DatabaseModel myDB]getArrayFrom:@"valuation" whereData:[[NSDictionary alloc]initWithObjectsAndKeys:@"FLANK",@"FLANKCENTRE", nil] sortFieldAsc:@""];
            
            NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionary];
            [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempDictionary setObject:obj forKey:[(NSDictionary*) obj objectForKey:@"POSITION"]];
            }];
            [[GlobalVariableModel myGlobalVariableModel] setValuationStatListFlank:tempDictionary];
        }
        return myGlobalVariableModel.valuationStatListFlank;
    }
    return  nil;
}


+ (NSDictionary *)standardDeviationTable {
    if (!myGlobalVariableModel.standardDeviationTable){
        [[GlobalVariableModel myGlobalVariableModel] setStandardDeviationTable: [[DatabaseModel myDB]getStandardDeviationTable]];
    }
    return myGlobalVariableModel.standardDeviationTable;
}

+ (NSDictionary*) tournamentList
{
    if (!myGlobalVariableModel.tournamentList){
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [[[DatabaseModel myDB]getArrayFrom:@"tournaments" withSelectField:@"TOURNAMENTID" whereKeyField:@"" hasKey:@""] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result setObject:[[Tournament alloc]initWithTournamentID:[obj integerValue]] forKey:[NSString stringWithFormat:@"%@",obj]];
        }];
        [[GlobalVariableModel myGlobalVariableModel]setTournamentList:result];
    }
    return myGlobalVariableModel.tournamentList;
}

# pragma mark Training Methods

+ (NSDictionary*) statBiasTable {
    if (!myGlobalVariableModel.statBiasTable){
        
        NSArray* statBiasList = [[DatabaseModel myDB]getArrayFrom:@"statBias" whereData:nil sortFieldAsc:@""];
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [statBiasList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result setObject:obj forKey:[[obj objectForKey:@"STATBIASID"]stringValue]];
        }];
        [[GlobalVariableModel myGlobalVariableModel] setStatBiasTable:result];
    }
    
    return myGlobalVariableModel.statBiasTable ;
}


+ (NSDictionary*) ageProfile
{
    if (!myGlobalVariableModel.ageProfile){
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        
        NSArray* allProfiles = [[DatabaseModel myDB]getArrayFrom:@"trainingProfile" whereData:nil sortFieldAsc:@""];
        [allProfiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([result objectForKey:[[obj objectForKey:@"AGE"]stringValue]]) {
                NSMutableDictionary* profile = [result objectForKey:[obj objectForKey:@"AGE"]];
                [profile setObject:obj forKey:[[obj objectForKey:@"PROFILEID"]stringValue]];
            } else {
                NSMutableDictionary* profile = [NSMutableDictionary dictionary];
                [profile setObject:obj forKey:[[obj objectForKey:@"PROFILEID"]stringValue]];
                [result setObject:profile forKey:[[obj objectForKey:@"AGE"]stringValue]];
            }
        }];
        
        [[GlobalVariableModel myGlobalVariableModel]setAgeProfile:result];
    }
    return myGlobalVariableModel.ageProfile;
}


/*
+ (NSArray*) decayProfile
{
    if (!myGlobalVariableModel.decayProfile){
        NSMutableArray* profileArray = [NSMutableArray array];
        
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        
        NSArray* allProfiles = [[[DatabaseModel alloc]init]getArrayFrom:@"trainingProfile" whereData:nil sortFieldAsc:@""];
        
        [allProfiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([result objectForKey:[[obj objectForKey:@"AGE"]stringValue]]) {
                NSMutableDictionary* profile = [result objectForKey:[obj objectForKey:@"AGE"]];
                [profile setObject:obj forKey:[[obj objectForKey:@"PROFILEID"]stringValue]];
            } else {
                NSMutableDictionary* profile = [NSMutableDictionary dictionary];
                [profile setObject:obj forKey:[[obj objectForKey:@"PROFILEID"]stringValue]];
                [result setObject:profile forKey:[[obj objectForKey:@"AGE"]stringValue]];
            }
        }];
        
        [[GlobalVariableModel myGlobalVariableModel]setDecayProfile:result];
    }
    return myGlobalVariableModel.decayProfile;
}
*/

+ (NSMutableArray*) playerStatList{
    return [[NSMutableArray alloc]initWithObjects:
     @"PAS", @"LPA", @"HEA",  @"SHO", @"TAC", @"AGI", @"CRO",  @"DRI", @"MOV", @"POS",
     @"LSH", @"PEN", @"FRE", @"SPE", @"STR",  @"FIT", @"WOR", @"TEC", @"INT",  @"TEA",nil];
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

+ (NSMutableArray*) gkStatList{
    return [[NSMutableArray alloc]initWithObjects:
    @"DIS", @"HAN", @"AGI", @"REF", @"PHY", @"COM",
    @"POS", @"PEN", @"INT", @"FRE", @"TEC", @"TEA",nil];
}

- (void) setAllStatList
{
    allStatList = [[NSMutableArray alloc]initWithObjects:
                      @"PAS", @"LPA", @"HEA", @"SHO", @"TAC",
                      @"AGI", @"CRO", @"DRI", @"MOV", @"POS",
                      @"LSH", @"PEN", @"FRE", @"SPE", @"STR",
                      @"FIT", @"WOR", @"TEC", @"INT", @"TEA",
                      @"DIS", @"HAN", @"REF", @"PHY", @"COM", nil];
}

- (void) setEventOccurenceFactorTableFromDB
{
    eventOccurenceFactorTable = [[DatabaseModel myDB]getEventOccurenceFactorTable];
}


+ (NSDictionary*) getProbResultFromTable:(NSString*) tbl ZoneFlank:(ZoneFlank)zf PositionSide:(PositionSide) ps AttackType:(NSString*) atype DefenseType:(NSString*) dtype isDynamicProb:(BOOL) isProbDy Team:(LineUp*) team PositionSideToExclude:(PositionSide) exPS
{
    if (!myGlobalVariableModel.probTables)
        myGlobalVariableModel.probTables = [NSMutableDictionary dictionary];
    
    __block NSMutableArray* resultList = [NSMutableArray array];
    __block NSInteger sumProb = 0;
    __block NSInteger cumuProb = 0;
    __block double prob = (double) (arc4random() % 10000);
    __block NSDictionary* result;
    
    if (![myGlobalVariableModel.probTables objectForKey:tbl]) {
        NSArray* dataTable = [[DatabaseModel myDB]getArrayFrom:tbl whereData:nil sortFieldAsc:@""];
        [myGlobalVariableModel.probTables setObject:dataTable forKey:tbl];
    }
    NSArray* enumList = [myGlobalVariableModel.probTables objectForKey:tbl];
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
            
            //if (![obj objectForKey:@"PROB"])
              //  [NSException raise:@"table returns no prob" format:@"table %@ returns no prob",tbl];
            
            if (exPS.position != PositionCount ) {
                PositionSide ps = [Structs getPositionSideFromTextWithPosition:[obj objectForKey:@"OUTPOSITION"] Side:[obj objectForKey:@"OUTSIDE"]];
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
    
    return result;
}

+ (NSDictionary*) getSGridForType:(NSString*)type Coeff:(NSString*)coeff {
    NSString* key = [NSString stringWithFormat:@"%@%@",type,coeff];
    if (!myGlobalVariableModel.sGridTables)
        myGlobalVariableModel.sGridTables = [NSMutableDictionary dictionary];
    
    if (![myGlobalVariableModel.sGridTables objectForKey:key]) {
        NSDictionary* grid = [[DatabaseModel myDB]getResultDictionaryForTable:@"SGrid" withDictionary:[[NSMutableDictionary alloc]initWithObjectsAndKeys:type,@"TYPE",coeff,@"STATTYPE", nil]];
        if (!grid)
            [NSException raise:@"empty sGrid" format:@"empty SGrid %@",key];
        [myGlobalVariableModel.sGridTables setObject:grid forKey:key];
    }
    
    
    return [myGlobalVariableModel.sGridTables objectForKey:key];
}

+ (NSInteger) getAttackOutcomesForZoneFlank:(ZoneFlank) zf AttackType:(NSString*) type
{
    if (!myGlobalVariableModel.attackOutcomeTables)
        myGlobalVariableModel.attackOutcomeTables = [[DatabaseModel myDB]getArrayFrom:@"AttackOutcome_ZFAtt" whereData:[[NSDictionary alloc]initWithObjectsAndKeys:@"OUTCOME",@"Fail", nil] sortFieldAsc:@""];
    __block double result = 0.0;
    
    [myGlobalVariableModel.attackOutcomeTables enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
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

@end
