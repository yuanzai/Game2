//
//  PlayerList.m
//  Game2
//
//  Created by Junyuan Lau on 26/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlayerList.h"
#import "Player.h"
#import "GlobalVariableModel.h"
#import "GameModel.h"
#import "Team.h"
#import "PlayerInfoViewController.h"
#import "LineUp.h"
#import "Training.h"
@implementation PlayerList
{
    GameModel* myGame;
    NSDictionary* source;
}
@synthesize target;
@synthesize players;
@synthesize viewSource;
- (id) initWithTarget:(id) thisTarget Source:(NSDictionary*) thisSource;
{
    self = [super init];
    if (self) {
        source = thisSource;
        target = thisTarget;
        myGame = [GameModel myGame];
        viewSource = [thisSource objectForKey:@"source"];
        [self loadData];
    }
    return self;
}


- (void) loadData
{
    if ([viewSource isEqualToString:@"enterTactic"]) {
        players = [[[myGame myData]myTeam]PlayerList];
    } else if ([viewSource isEqualToString:@"enterPlan"]){
        Plan* thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:[[source objectForKey:@"PlanID"]integerValue]];
        players = thisPlan.Players;
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [players count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"player";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Player* p = [myGame.myData.myTeam.PlayerList objectAtIndex:indexPath.row];
    cell.textLabel.font = [GlobalVariableModel newFont2Medium];
    cell.textLabel.text = p.DisplayName;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerInfoViewController *vc = [((UIViewController*)target).storyboard instantiateViewControllerWithIdentifier:@"playerInfo"];
    vc.thisPlayer = [myGame.myData.myTeam.PlayerList objectAtIndex:indexPath.row];
    vc.source = source;
    [(UIViewController*)target presentViewController:vc animated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([[source objectForKey:@"source"] isEqualToString:@"enterTactic"]) {
        Player* p = [myGame.myData.myTeam.PlayerList objectAtIndex:indexPath.row];
        [myGame.myData.currentLineup.currentTactic removePlayerFromTactic:p];
        PositionSide ps;
        [[source objectForKey:@"ps"] getValue:&ps];
        [myGame.myData.currentLineup.currentTactic populatePlayer:p PositionSide:ps ForceSwap:NO];
        [myGame enterTacticFrom:source];
    } else if ([[source objectForKey:@"source"] isEqualToString:@"enterPlan"]){
        
    }
}
@end
