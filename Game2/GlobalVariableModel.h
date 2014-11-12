//
//  GlobalVariableModel.h
//  MatchEngine
//
//  Created by Junyuan Lau on 01/05/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVariableModel : NSObject
@property NSMutableArray* playerStatList;
@property NSMutableArray* gkStatList;
@property NSMutableDictionary* playerGroupStatList;
@property NSMutableArray* allStatList;
@property NSMutableDictionary* eventOccurenceFactorTable;

@property NSDictionary* valuationStatListCentre;
@property NSDictionary* valuationStatListFlank;
@property NSDictionary* valuationStatListGK;

//Training
@property NSDictionary* ageProfile;
@property NSDictionary* statBiasTable;

//Match Variables
@property NSDictionary* standardDeviationTable;
@property NSDictionary* actionStartTable;
@property NSDictionary* tournamentTable;

//TournamentList
@property NSDictionary* tournamentList;

+ (GlobalVariableModel*)myGlobalVariableModel;
- (void)setEventOccurenceFactorTableFromDB;

// Stat List
+ (NSDictionary*)valuationStatListForFlank:(NSString*) flank;

+ (NSMutableArray*) playerStatList;
+ (NSMutableArray*) gkStatList;
+ (NSMutableDictionary*) playerGroupStatList;

// Game Engine Prob Tables
+ (NSDictionary *)standardDeviationTable;
+ (NSDictionary*) actionStartTable;

// Training Tables
+ (NSDictionary*) statBiasTable;
+ (NSDictionary*) ageProfile;

@end
