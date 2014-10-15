//
//  GlobalVariableModel.h
//  MatchEngine
//
//  Created by Junyuan Lau on 01/05/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVariableModel : NSObject
{
    NSMutableArray* playerStatList;
    NSMutableArray* gkStatList;
    NSMutableArray* allStatList;
    NSMutableDictionary* playerGroupStatList;
    NSMutableDictionary* statsEventTable;
    NSMutableDictionary* eventOccurenceFactorTable;
    NSMutableArray* attackTypes;
    
    NSDictionary* ActionStartTable;
    NSDictionary* standardDeviationTable;

}
@property NSMutableArray* playerStatList;
@property NSMutableArray* gkStatList;
@property NSMutableDictionary* playerGroupStatList;
@property NSMutableArray* allStatList;
@property NSMutableDictionary* statsEventTable;
@property NSMutableDictionary* eventOccurenceFactorTable;
@property NSMutableArray* attackTypes;

@property NSDictionary* standardDeviationTable;
@property NSDictionary* actionStartTable;


+ (GlobalVariableModel*)myGlobalVariableModel;
- (void)setEventOccurenceFactorTableFromDB;
- (NSDictionary*) statsEventTable:(NSString *)type WithPosition:(NSString*)position WithSide:(NSString*)sidetype;
- (void)setAttackTypes;

// Stat List
+ (NSMutableArray*) playerStatList;
+ (NSMutableArray*) gkStatList;
+ (NSMutableDictionary*) playerGroupStatList;

// Game Engine Prob Tables
+ (NSDictionary *)standardDeviationTable;
+ (NSDictionary*) actionStartTable;


@end
