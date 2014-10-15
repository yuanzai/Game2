//
//  GlobalVariableModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 01/05/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "GlobalVariableModel.h"
#import "DatabaseModel.h"

@implementation GlobalVariableModel
@synthesize playerStatList,gkStatList, allStatList, statsEventTable,eventOccurenceFactorTable,attackTypes, playerGroupStatList, standardDeviationTable, actionStartTable;
static GlobalVariableModel* myGlobalVariableModel;

+ (GlobalVariableModel*)myGlobalVariableModel
{
    if (!myGlobalVariableModel) {
        myGlobalVariableModel = [[GlobalVariableModel alloc] init];
        [myGlobalVariableModel setPlayerStatList];
        [myGlobalVariableModel setGkStatList];
        [myGlobalVariableModel setAllStatList];
        [myGlobalVariableModel setEventOccurenceFactorTableFromDB];
        //[myGlobalVariableModel setAttackTypes];
        
    }
    return myGlobalVariableModel;
}

+ (NSDictionary *)standardDeviationTable {
    if (!myGlobalVariableModel.standardDeviationTable){
        myGlobalVariableModel.standardDeviationTable = [[[DatabaseModel alloc]init]getStandardDeviationTable];
    }
    return myGlobalVariableModel.standardDeviationTable;
}

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
     @"DIS", @"HAN", @"AGI",  @"REF", @"PEN", @"FRE", @"POS",
     @"PHY", @"COM", @"FIT",  @"TEC", @"INT", @"TEA",nil];
}


- (void)setPlayerStatList
{
    playerStatList = [[NSMutableArray alloc]initWithObjects:
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
                       @"TEA",nil];
    
}

- (void)setGkStatList
{
    gkStatList = [[NSMutableArray alloc]initWithObjects:
                      @"DIS",
                      @"HAN",
                      @"AGI",
                      @"REF",
                      @"PEN",
                      @"FRE",
                      @"POS",
                      @"PHY",
                      @"COM",
                      @"FIT",
                      @"TEC",
                      @"INT",
                      @"TEA",nil];
    
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

- (NSDictionary*) statsEventTable:(NSString *)type WithPosition:(NSString*)position WithSide:(NSString*)sidetype
{
    return [statsEventTable objectForKey:[NSString stringWithFormat:@"%@|%@|%@",type,position,sidetype]];
}

-(void)setAttackTypes
{
    gkStatList = [[NSMutableArray alloc]initWithObjects:
                  @"SHORTPASS",
                  @"LONGPASS",
                  @"DRIBBLE",
                  @"CROSS",
                  @"FIRSTTOUCH",
                  @"HEADEDPASS",
                  @"HEADERSHOT",
                  @"LAYOFF",
                  @"SHOT",
                  @"LONGSHOT",
                  @"MAKINGRUN",
                  @"RECEIVING",
                  @"FAIL",nil];
}
@end
