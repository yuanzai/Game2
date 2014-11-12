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

@implementation GlobalVariableModel

@synthesize playerStatList,gkStatList, allStatList,eventOccurenceFactorTable, playerGroupStatList, standardDeviationTable, actionStartTable, valuationStatListCentre, valuationStatListFlank, tournamentTable, tournamentList ;

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
        [[GlobalVariableModel myGlobalVariableModel] setStandardDeviationTable: [[[DatabaseModel alloc]init]getStandardDeviationTable]];
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
        
        NSArray* statBiasList = [[[DatabaseModel alloc]init]getArrayFrom:@"statBias" whereData:nil sortFieldAsc:@""];
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

+ (NSDictionary*) actionStartTable
{
    if (!myGlobalVariableModel.actionStartTable){
        NSArray* data = [[[DatabaseModel alloc]init]getArrayFrom:@"ActionStartTable" whereKeyField:@"" hasKey:@"" sortFieldAsc:@"PROB"];
        NSMutableDictionary* result = [[NSMutableDictionary alloc]init];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [result setObject:obj forKey:[NSString stringWithFormat:@"%i",[[obj objectForKey:@"PROB"]integerValue]]];
        }];
        myGlobalVariableModel.actionStartTable = result;
    }
    return myGlobalVariableModel.actionStartTable;
}

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
                      @"PAS",
                      @"LPA",
                      @"HEA",
                      @"SHO",
                      @"TAC",
                      @"AGI",
                      @"CRO",
                      @"DRI",
                      @"MOV",
                      @"POS",
                      @"LSH",
                      @"PEN",
                      @"FRE",
                      @"SPE",
                      @"STR",
                      @"FIT",
                      @"WOR",
                      @"TEC",
                      @"INT",
                      @"TEA",
                      @"DIS",
                      @"HAN",
                      @"REF",
                      @"PHY",
                      @"COM",
                      nil];
}

- (void) setEventOccurenceFactorTableFromDB
{
    eventOccurenceFactorTable = [[[DatabaseModel alloc]init]getEventOccurenceFactorTable];
}


@end
