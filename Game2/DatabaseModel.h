//
//  DatabaseModel.h
//  MatchEngine
//
//  Created by Junyuan Lau on 30/04/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "GlobalVariableModel.h"
#import "Math.h"
/*
#import <gsl/gsl_types.h>
#import <gsl/gsl_cdf.h>
#import <gsl/gsl_rng.h>
#import <gsl/gsl_randist.h>
*/
@interface DatabaseModel : NSObject
{
    FMDatabase* db;
    NSString* databasePath;
}
-(id)initWithPath:(NSString*) path;


//Event
- (NSMutableDictionary*) getStandardDeviationTable;
- (NSMutableDictionary*) getEventOccurenceFactorTable;
- (NSMutableDictionary*) getStatsEventTable;


//Tournament
-(NSArray*) getLeagueTableForTournamentID:(NSInteger) tournamentID Season:(NSInteger)season;


//Generic CRUD - get resultDictionary
- (NSDictionary*) getResultDictionaryForTable:(NSString*)table withKeyField:(NSString*)keyField withKey:(NSInteger)key;
- (NSDictionary*) getResultDictionaryForTable:(NSString*)table withDictionary:(NSDictionary*) data;



//Generic CRUD - get Array
- (NSArray*) getArrayFrom:(NSString*)table whereData:(NSDictionary*)data sortFieldAsc:(NSString*) sortAsc;
- (NSArray*) getArrayFrom:(NSString*)table whereKeyField:(NSString*)keyField hasKey:(id)key sortFieldAsc:(NSString*) sortAsc;

- (NSArray*) getArrayFrom:(NSString*)table withSelectField:(NSString*)selectField whereKeyField:(NSString*)keyField hasKey:(NSInteger)key;


//Generic CRUD - update
- (BOOL) updateDatabaseTable:(NSString*) table withKeyField:(NSString*)keyField withKey:(NSInteger)key withDictionary:(NSDictionary*) data;



// INSERT QUERY
- (BOOL) insertDatabaseTable:(NSString*) table withData:(NSDictionary*) data;

@end
