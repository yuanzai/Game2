//
//  PlayerList.m
//  Game2
//
//  Created by Junyuan Lau on 26/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlayerList.h"
#import "GameModel.h"
#import "PlayerInfoViewController.h"
#import "LineUp.h"
#import "Training.h"

#import "PlanViewController.h"

@implementation PlayerList
{
    GameModel* myGame;
    NSInteger sectionCount;
    NSMutableArray* sectionNames;
    NSString* sourceString;
}
@synthesize target;
@synthesize players;
- (id) initWithTarget:(id) thisTarget Source:(NSDictionary*) thisSource;
{
    self = [super init];
    if (self) {
        target = thisTarget;
        myGame = [GameModel myGame];
        sourceString = [myGame.source objectForKey:@"source"];
        players = [NSMutableArray array];
        sectionNames = [NSMutableArray array];
        sectionCount = 0;
        [self loadData];
    }
    return self;
}


- (void) loadData
{
    if ([sourceString isEqualToString:@"enterTactic"] || [sourceString isEqualToString:@"enterPreGame"]) {
        PositionSide ps;
        [[myGame.source objectForKey:@"ps"] getValue:&ps];

        if (ps.position == GKPosition && ps.side == GKSide) {
            [players addObject: [myGame.myData.myTeam getAllGKWithInjured:NO]];
        } else {
            [players addObject: [myGame.myData.myTeam getAllOutfieldWithInjured:NO]];
        }
        sectionCount = 1;
    } else if ([sourceString isEqualToString:@"enterPlan"]){

        Plan* thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:[[myGame.source objectForKey:@"PlanID"]integerValue]];
        if ([thisPlan.PlayerList count] > 0)
            [players addObject: [thisPlan.PlayerList allObjects]];
        sectionCount = 1;
        
    } else if ([sourceString isEqualToString:@"enterPlanPlayers"]){
        sectionCount = 0;
        NSLog(@"Unassigned %i",[[[[myGame myData]myTraining] getUnassignedPlayers]count]);
        if ([[[[myGame myData]myTraining] getUnassignedPlayers]count] > 0) {
            [players addObject:[[[myGame myData]myTraining] getUnassignedPlayers]];
            [sectionNames addObject:@"Unassigned Players"];
            sectionCount++;
        }
        for (NSInteger i = 0; i<4; i++) {
            if ([[myGame.source objectForKey:@"PlanID"]integerValue] == i)
                continue;
            Plan* thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:i];
            if ([thisPlan.PlayerList count] > 0) {
                sectionCount++;
                [players addObject: [thisPlan.PlayerList allObjects]];
                [sectionNames addObject:[NSString stringWithFormat:@"Plan %i",i+1]];
            }
        }
    }
}
#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([sectionNames count]> 0) {
        return [sectionNames objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([players count] == 0)
        return 0;
    
    
    if (![players objectAtIndex:section])
        return 0;
//    if ([[players objectAtIndex:section ] count] == 0)
//       return 0;
    return [[players objectAtIndex:section ] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"player";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Player* p = [[players objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    cell.textLabel.font = [GlobalVariableModel newFont2Medium];
    cell.textLabel.text = p.DisplayName;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [myGame.source setObject:[[players objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] forKey:@"player"];
    [myGame enterPlayerInfo];
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Player* p = [[players objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([sourceString isEqualToString:@"enterTactic"] || [sourceString isEqualToString:@"enterPreGame"]) {
        [myGame.myData.currentLineup.currentTactic removePlayerFromTactic:p];
        PositionSide ps;
        [[myGame.source objectForKey:@"ps"] getValue:&ps];
        [myGame.myData.currentLineup.currentTactic populatePlayer:p PositionSide:ps ForceSwap:NO];
        [myGame.myData.currentLineup.currentTactic updatePlayerLineup];
        [myGame enterTactic];
    } else if ([sourceString  isEqualToString:@"enterPlan"]){
        Plan* thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:[[myGame.source objectForKey:@"PlanID"]integerValue]];
        [thisPlan.PlayerList removeObject:p];
        NSLog(@"%@",p.DisplayName);
        [tableView reloadData];

        [(PlanViewController*)target refreshTable];
    }  else if ([sourceString isEqualToString:@"enterPlanPlayers"]){
        for (NSInteger i = 0; i<4; i++) {
            Plan* thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:i];

            if ([[myGame.source objectForKey:@"PlanID"]integerValue] == i) {
                [thisPlan addPlayerToTrainingPlan:p];
            } else if ([thisPlan.PlayerList containsObject:p]) {
                [thisPlan.PlayerList removeObject:p];
            }
        }
        [myGame enterPlan];
    }

}
@end
