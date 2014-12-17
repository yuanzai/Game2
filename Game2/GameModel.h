//
//  GameModel.h
//  MatchEngine
//
//  Created by Junyuan Lau on 12/09/2013.
//  Copyright (c) 2013 Junyuan Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinglePlayerData.h"
#import "Structs.h"
#import "DatabaseModel.h"

@class SinglePlayerData;
@class Match;
@class DatabaseModel;
@class Player;

@interface GameModel : NSObject
@property SinglePlayerData* myData;
@property DatabaseModel* myDB;
@property UIStoryboard* myStoryboard;
@property NSInteger GameID;
@property NSMutableDictionary* source;

/* -- Playables --

 -- Actionables --
1) Main Menu
 - New Game
 - Load Game
 
2) Views
 
 [PRE WEEK]
 - process date
 - process next match
 - process last match
 
 Highlights
 - see training result
 - see match training result
 - see scout results
 - see task results
 
 - see news
 - see awards/injuries(training + match)/cards
 - see transfer requests/ transfer approaches
    - boost in player value
 
 - [end season] see prize money
 - [end season] see prize money
 - [new season] see season tickets
 - [new season] youth players
 
 News
 - see special actionables
    - choose to accept or decline/decline special actionables

 [PRE TASK]
 Menu
 - choose sub view to enter

    Fixtures subview
    - see table
    - see fixtures
    - see next match
       - opponent form/ position

    Squad subview
    - see player stats
    - see player season stats
      - games played
      - goals

    Tactics subview
    - see current tactic
    - choose formation
    - choose player in formation

    Admin subview
    - see scouts + coaches
    - see available scouts + coaches
    - choose scout to hire
    - choose scout to fire
    - choose coach to hire
    - choose coach to fire
    - see finances

    Training subview
    - see training plans
    - see available coaches
    - choose training plan settings/ coach for plan
    - choose players for plan

    Transfer subview
    - see shortlist
    - choose player to buy from shortlist
    - choose player to remove from shortlist
    - choose existing player to sell
    - choose existing player to list for sale

 [TASK]
 Start week
 - choose week's task
   - scout
     - you
     - (high count, low quality)
     - (low quality, high count)
 
   - train
     - team + 2x area training? or 1x general training?
     - player + 5x area trainings @ max intensity + 1 x normal training
     - motivation (up form for % of team) form + 1 for 1/3 of team, form + 2 for 1/6
   
   - match prep
     - watch videos - boost effectiveness
     -
 
   - admin
     - cash
     - refresh job seekers
     - football seminar
 
 [POST TASK]
 - nil
 
 [PRE GAME]
 Prematch Selection
 - see form/condition of players
 - choose formation
 - choose players
 
 [GAME]
 - process opponent selection
 
 Game
 - see game
 - choose pause
 - choose sub
 - choose formation
 
 [POST GAME]
 - process tournament games played
 - process single player fixture
 - process cash

 - process training
 - process scouting
 - process admin
 - process task

 
 - [SCENE] bus travelling with weather depending on result
 - [SCENE] see lastgame result
 - [SCENE] see other league result
 - [SCENE] see table standing
*/


//Static Method
+ (id)myGame;
+ (DatabaseModel*) myDB;
//+ (GlobalVariableModel*) myGlobalVariableModel;

//Save Load
- (void) newWithGameID:(NSInteger) thisGameID;
- (void) loadWithGameID:(NSInteger) thisGameID;
- (void) saveThisGame;

//Seaons
- (void) startSeason;

//Turns
+ (SinglePlayerData*) gameData;
- (void) enterPreWeek; // do admin, player transfers, news
- (void) enterPreTask; // select the task this week
- (void) setTask:(WeekTask) task;
- (void) enterTask; // do other stuff etc, see tactics buy players etc
- (void) enterPostTask; // show task results
- (void) enterPreGame; // show match day form
- (void) enterGame; // goto game
- (void) enterPostGame;

//Parellel views
- (void) enterTactic;
- (void) exitTactic;


- (void) enterPlayers;
- (void) exitPlayers;
- (void) enterPlayerInfo;


- (void) enterTraining;
- (void) enterPlan;

@end
