//
//  DatabaseModel.m
//  MatchEngine
//
//  Created by Junyuan Lau on 30/04/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import "DatabaseModel.h"
#import "AppDelegate.h" 

@implementation DatabaseModel

-(id)init
{
	if (!(self = [super init]))
		return nil;
    databasePath = [(AppDelegate *)[[UIApplication sharedApplication] delegate] databasePath];
    
    if (!databasePath) {
        //For unit test purpose as app delegate did not run
        /*
          NSString* databaseName = @"database.db";
          databasePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:databaseName];
          [self getDBPath];
          [self createAndCheckDatabase];
         */
    }


    db = [FMDatabase databaseWithPath:databasePath];
    return self;
}

- (void) getDBPath
{
    NSString* databaseName = @"database.db";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    databasePath = [documentDir stringByAppendingPathComponent:databaseName];
    
}

-(void) createAndCheckDatabase
{
    BOOL success;
    NSString* databaseName = @"database.db";

    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    
    if(success) return;
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}


-(id)initWithPath:(NSString*) path
{
	if (!(self = [super init]))
		return nil;
    db = [FMDatabase databaseWithPath:path];
    
    return self;
}

- (NSMutableDictionary*) getStandardDeviationTable
{
    NSMutableDictionary* resultTable = [[NSMutableDictionary alloc] init];
    [db open];
    NSString* query =@"SELECT * FROM statssd";
    FMResultSet *results = [db executeQuery:query];
    
    while([results next])
    {
        [resultTable setObject:[NSNumber numberWithDouble:[results doubleForColumn:@"SD"]] forKey:[NSString stringWithFormat:@"%i",[results intForColumn:@"STAT"]]];
    }
    
    [db close];

    return resultTable;
}

- (NSMutableDictionary*) getStatsEventTable
{
    NSArray* matchStatsTable =[[GlobalVariableModel myGlobalVariableModel]playerStatList];
    NSMutableDictionary* resultTable = [[NSMutableDictionary alloc] init];
    [db open];
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM statsEvent"];
    
    while([results next])
    {
        NSMutableDictionary* singleLine = [[NSMutableDictionary alloc]init];
        
        for (int i=0; i < matchStatsTable.count; i++) {
            NSString* stat = [matchStatsTable objectAtIndex:i];
            [singleLine setObject:[NSNumber numberWithDouble:[results doubleForColumn:stat]] forKey:stat];
        }
        [singleLine setObject:[NSNumber numberWithDouble:[results doubleForColumn:@"CONSISTENCY"]] forKey:@"CON"];
        NSString * concatKey= [NSString stringWithFormat:@"%@|%@|%@", [results stringForColumn:@"TYPE"],[results stringForColumn:@"POSITION"],[results stringForColumn:@"SIDETYPE"]];
        
        [resultTable setObject:singleLine forKey:concatKey];
    }
    
    [db close];
    return resultTable;
}

- (NSMutableDictionary*) getEventOccurenceFactorTable
{
    NSMutableDictionary* resultTable = [[NSMutableDictionary alloc] init];
    [db open];
    FMResultSet *results = [db executeQuery:@"SELECT * FROM probEvent"];
    while([results next])
    {
        NSString* factor = [results stringForColumn:@"FACTOR"];
        NSNumber* value = [NSNumber numberWithDouble:[results doubleForColumn:@"VALUE"]];
        [resultTable setObject:value forKey:factor];
    }
    [db close];
    return resultTable;
}

-(NSArray*) getLeagueTableForTournamentID:(NSInteger) tournamentID Season:(NSInteger)season {
    NSMutableArray* resultArray = [NSMutableArray array];
    [db open];
    NSString* query = [NSString stringWithFormat:@
                       " SELECT AWAYTEAM as TEAM, AWAYSCORE as GOALSFOR, HOMESCORE as GOALSAGAINST,"
                       " CASE WHEN HOMESCORE < AWAYSCORE THEN '3' WHEN HOMESCORE = AWAYSCORE THEN '1' else '0' END as POINT,"
                       " CASE WHEN HOMESCORE < AWAYSCORE THEN '1'else '0' END as WIN,"
                       " CASE WHEN HOMESCORE = AWAYSCORE THEN '1'else '0' END as DRAW,"
                       " CASE WHEN HOMESCORE > AWAYSCORE THEN '1'else '0' END as LOSS"
                       " FROM fixtures WHERE"
                       " TOURNAMENTID = %i AND SEASON = %i"
                       " UNION ALL"
                       " SELECT HOMETEAM as TEAM, HOMESCORE as GOALSFOR, AWAYSCORE as GOALSAGAINST,"
                       " CASE WHEN HOMESCORE > AWAYSCORE THEN '3' WHEN HOMESCORE = AWAYSCORE THEN '1' else '0' end as POINT,"
                       " CASE WHEN HOMESCORE > AWAYSCORE THEN '1'else '0' END as WIN,"
                       " CASE WHEN HOMESCORE = AWAYSCORE THEN '1'else '0' END as DRAW,"
                       " CASE WHEN HOMESCORE < AWAYSCORE THEN '1'else '0' END as LOSS"
                       " FROM fixtures WHERE"
                       " TOURNAMENTID = %i AND SEASON = %i",tournamentID,season,tournamentID,season];
    
    query = [NSString stringWithFormat:@"SELECT TEAM, SUM(WIN) + SUM(DRAW) + SUM(LOSS) as GP, SUM(WIN) as WIN, SUM(DRAW) as DRAW, SUM(LOSS) as LOSS, SUM(POINT) as POINTS, SUM(GOALSFOR) as GF, SUM(GOALSAGAINST) as GA, (SUM(GOALSFOR) - SUM(GOALSAGAINST)) as GD FROM (%@) GROUP BY TEAM ORDER BY POINTS DESC",query];
    
    
    FMResultSet* result=[db executeQuery:query];
    while([result next]) {
        [resultArray addObject:[result resultDictionary]];
    }
    [db close];
    return resultArray;
}

- (NSDictionary*) getResultDictionaryForTable:(NSString*)table withKeyField:(NSString*)keyField withKey:(NSInteger)key
{
    [db open];
    NSString* query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %i", table, keyField,key];
    FMResultSet* result = [db executeQuery:query];
    if ([result next]) {
        NSDictionary* ret = [result resultDictionary];
        [db close];
        return ret;
        
    } else {
        [db close];
        return nil; //has 0 entry in this key field
    }
}

- (NSDictionary*) getResultDictionaryForTable:(NSString*)table withDictionary:(NSDictionary*) data
{
    if ([data count] == 0)
        return nil;
    [db open];
    NSMutableArray* whereValues = [[NSMutableArray alloc]init];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //[obj class];
        if ([obj isKindOfClass:[NSString class]]){
            [whereValues addObject:[NSString stringWithFormat:@"%@ = '%@'",key, obj]];
        } else {
            [whereValues addObject:[NSString stringWithFormat:@"%@ = %@",key, obj]];
        }
    }];
    NSString* whereString = [whereValues componentsJoinedByString:@","];
    
    NSString* query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", table, whereString];
    FMResultSet* result = [db executeQuery:query];
    if ([result next]) {
    	NSDictionary* ret = [result resultDictionary];
        if ([result next]) {
            [db close];
            return nil; // has more than 1 entry
        }
        [db close];
        return ret;
    } else {
        [db close];
        return nil; //has 0 entry in this key field
    }
}

- (NSArray*) getArrayFrom:(NSString*)table withSelectField:(NSString*)selectField whereKeyField:(NSString*)keyField hasKey:(id)key
{
    [db open];
    NSString* query;
    if ([keyField isEqualToString:@""]) {
        query = [NSString stringWithFormat:@"SELECT %@ FROM %@", selectField, table];
    } else if ([key isKindOfClass:[NSString class]]){
        query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = '%@'", selectField, table,keyField,key];
    } else {
        query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %@", selectField, table,keyField,key];
    }
    
    FMResultSet* result = [db executeQuery:query];

    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    while ([result next]){
        [resultArray addObject:[result objectForColumnName:selectField]];
    }
    
    [db close];
    if ([resultArray count] == 0)
        return nil;
    return resultArray;
}

- (NSArray*) getArrayFrom:(NSString*)table whereData:(NSDictionary*)data sortFieldAsc:(NSString*) sortAsc
{

    [db open];
    NSString* query;
    NSString* sortSQL;
    NSString* whereSQL = @"";
    
    if ([data count] > 0) {
        NSMutableArray* whereValues = [[NSMutableArray alloc]init];
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]){
                if (![((NSString*)obj) isEqualToString:@""])
                    [whereValues addObject:[NSString stringWithFormat:@"%@ = '%@'",key, obj]];
            } else {
                [whereValues addObject:[NSString stringWithFormat:@"%@ = %@",key, obj]];
            }
        }];
        if ([whereValues count] > 0)
            whereSQL = [NSString stringWithFormat:@"WHERE %@",[whereValues componentsJoinedByString:@","]];
    } else {
        whereSQL = @"";
    }
    
    if ([sortAsc isEqualToString:@""]) {
        sortSQL = @"";
    } else {
        sortSQL = [NSString stringWithFormat:@"ORDER BY %@ ASC", sortAsc];
    }
    
    query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ %@", table, whereSQL,sortSQL];

    FMResultSet* result = [db executeQuery:query];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    while ([result next]){
        [resultArray addObject:[result resultDictionary]];
    }
    if ([resultArray count] == 0)
    	resultArray = nil;
    [db close];
    return resultArray;
}

- (NSArray*) getArrayFrom:(NSString*)table whereKeyField:(NSString*)keyField hasKey:(id)key sortFieldAsc:(NSString*) sortAsc
{
    if ([keyField isEqualToString:@""])
        return [self getArrayFrom:table whereData:[[NSDictionary alloc]init] sortFieldAsc:sortAsc];
    return [self getArrayFrom:table whereData:[[NSDictionary alloc]initWithObjectsAndKeys:keyField, key, nil] sortFieldAsc:sortAsc];
}

- (BOOL) updateDatabaseTable:(NSString*) table withKeyField:(NSString*)keyField withKey:(NSInteger)key withDictionary:(NSDictionary*) data
{
    [db open];

    NSString* query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %i", table, keyField,key];
    FMResultSet* result = [db executeQuery:query];
    if ([result next]) {
        if ([result next]) { //has more than 1 entry in this key field
            [db close];
            return NO;
        }
    } else {
        [db close];
        return NO; //has 0 entry in this key field
    }
    NSMutableArray* UpdateValues = [[NSMutableArray alloc]init];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //[obj class];
        if ([obj isKindOfClass:[NSString class]]){
            [UpdateValues addObject:[NSString stringWithFormat:@"%@ = '%@'",key, obj]];
        } else {
            [UpdateValues addObject:[NSString stringWithFormat:@"%@ = %@",key, obj]];
        }
    }];
    NSString* setString = [UpdateValues componentsJoinedByString:@","];
    
    query = [NSString   stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = %i",table,setString, keyField,key];
    if ([db executeUpdate:query]) {
        [db close];
        return YES;
    } else {
        [db close];
        return NO;
    }
}


- (BOOL) insertDatabaseTable:(NSString*) table withData:(NSDictionary*) data
{
    if (!data)
        return NO;
    
    NSArray* fields = [data allKeys];
    NSArray* values = [data allValues];
    NSMutableArray* newValues = [NSMutableArray array];
    
    if ([fields count] == 0 || [values count] == 0)
        return NO;
    
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]){
            if (![((NSString*)obj) isEqualToString:@""])
                [newValues addObject:[NSString stringWithFormat:@"'%@'", obj]];
        } else {
            [newValues addObject:[NSString stringWithFormat:@"%@", obj]];
        }
    }];
    
    NSString* fieldsString = [fields componentsJoinedByString:@","];
    NSString* valuesString = [newValues componentsJoinedByString:@","];
    
    [db open];
    NSString* query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", table,fieldsString,valuesString];
    BOOL ret = [db executeUpdate:query];
    [db close];
    return ret;
}
@end
