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

//Static Stats List
+ (NSMutableArray*) playerStatList;
+ (NSMutableArray*) gkStatList;
+ (NSMutableDictionary*) playerGroupStatList;

//Valuations
- (NSDictionary*)valuationStatListForFlank:(NSString*) flank;

//Training

- (NSDictionary*) statBiasTable;
- (NSDictionary*) ageProfile;

//Match Variables
- (NSMutableDictionary*) eventOccurenceFactorTable;
- (NSDictionary *)standardDeviationTable;
- (NSDictionary*) getProbResultFromTable:(NSString*) tbl ZoneFlank:(ZoneFlank)zf PositionSide:(PositionSide) ps AttackType:(NSString*) atype DefenseType:(NSString*) dtype isDynamicProb:(BOOL) isProbDy Team:(LineUp*) team PositionSideToExclude:(PositionSide) exPS;
- (NSDictionary*) getSGridForType:(NSString*)type Coeff:(NSString*)coeff;
- (NSInteger) getAttackOutcomesForZoneFlank:(ZoneFlank) zf AttackType:(NSString*) type;

//TournamentList

- (NSDictionary*) tournamentList;

//TeamList
- (NSDictionary*) teamList;

@end
