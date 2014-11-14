//
//  GlobalVariableModel.h
//  MatchEngine
//
//  Created by Junyuan Lau on 01/05/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
@class LineUp;
@interface GlobalVariableModel : NSObject
@property NSMutableArray* playerStatList;
@property NSMutableArray* gkStatList;
@property NSMutableDictionary* playerGroupStatList;
@property NSMutableArray* allStatList;

//Valuations
@property NSDictionary* valuationStatListCentre;
@property NSDictionary* valuationStatListFlank;
@property NSDictionary* valuationStatListGK;

//Training
@property NSDictionary* ageProfile;
@property NSDictionary* statBiasTable;

//Match Variables
@property NSMutableDictionary* eventOccurenceFactorTable;
@property NSDictionary* standardDeviationTable;
@property NSDictionary* tournamentTable;
@property NSMutableDictionary* probTables;
@property NSMutableDictionary* sGridTables;
@property NSArray* attackOutcomeTables;

//TournamentList
@property NSDictionary* tournamentList;
+ (NSDictionary*) tournamentList;


+ (GlobalVariableModel*)myGlobalVariableModel;
- (void)setEventOccurenceFactorTableFromDB;

// Stat List

+ (NSMutableArray*) playerStatList;
+ (NSMutableArray*) gkStatList;
+ (NSMutableDictionary*) playerGroupStatList;

//Valuatons
+ (NSDictionary*)valuationStatListForFlank:(NSString*) flank;


// Game Engine Prob Tables
+ (NSDictionary *)standardDeviationTable;
+ (NSDictionary*) getProbResultFromTable:(NSString*) tbl ZoneFlank:(ZoneFlank)zf PositionSide:(PositionSide) ps AttackType:(NSString*) atype DefenseType:(NSString*) dtype isDynamicProb:(BOOL) isProbDy Team:(LineUp*) team PositionSideToExclude:(PositionSide) exPS;
+ (NSDictionary*) getSGridForType:(NSString*)type Coeff:(NSString*)coeff;
+ (NSInteger) getAttackOutcomesForZoneFlank:(ZoneFlank) zf AttackType:(NSString*) type;

// Training Tables
+ (NSDictionary*) statBiasTable;
+ (NSDictionary*) ageProfile;

@end
