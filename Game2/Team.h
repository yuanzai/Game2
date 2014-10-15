//
//  Team.h
//  MatchEngine
//
//  Created by Junyuan Lau on 17/9/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Player;
@interface Team : NSObject{
    NSInteger TeamID;
    NSString* Name;
    NSMutableArray* PlayerIDList;
    NSMutableArray* PlayerList;
    NSMutableDictionary* PlayerDictionary;
    NSMutableDictionary* tableData;
    BOOL isSinglePlayer;
}
@property NSInteger TeamID;
@property NSMutableArray* PlayerList;
@property NSMutableArray* PlayerIDList;
@property NSMutableDictionary* PlayerDictionary;
@property NSMutableDictionary* tableData;
@property BOOL isSinglePlayer;

- (id) initWithTeamID:(NSInteger) InputID;
- (void) updateFromDatabase;
- (BOOL) updateToDatabase;
- (Player*) getPlayerWithID:(NSInteger) PlayerID;
@end
