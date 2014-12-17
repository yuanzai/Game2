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
#import "PlayersViewController.h"
#import "LineUp.h"
#import "Training.h"
#import "Scouting.h"

#import "PlayerInfoView.h"

#import "PlanViewController.h"
#import "ViewController.h"

@implementation PlayerList
{
    GameModel* myGame;
    NSInteger sectionCount;
    NSMutableArray* sectionNames;
    NSString* sourceString;
}
@synthesize target;
@synthesize players;

- (id) initWithTarget:(id) thisTarget
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
    if ([sourceString isEqualToString:@"enterPlayers"] || [sourceString isEqualToString:@"enterPreGame"]) {
        
        NSString* enterPlayersSource = [myGame.source objectForKey:@"enterPlayers"];
        
        if ([enterPlayersSource isEqualToString:@"enterTactic"] || [enterPlayersSource isEqualToString:@"enterPreGame"]) {
            PositionSide ps;
            [[myGame.source objectForKey:@"ps"] getValue:&ps];
            
            if (ps.position == GKPosition && ps.side == GKSide) {
                [players addObject: [myGame.myData.myTeam getAllGKWithInjured:NO]];
            } else {
                [players addObject: [myGame.myData.myTeam getAllOutfieldWithInjured:NO]];
            }
            sectionCount = 1;
        } else if ([enterPlayersSource isEqualToString:@"enterPlan"]){
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
        
    } else if ([sourceString isEqualToString:@"enterPlan"]){

        Plan* thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:[[myGame.source objectForKey:@"PlanID"]integerValue]];
        if ([thisPlan.PlayerList count] > 0)
            [players addObject: [thisPlan.PlayerList allObjects]];
        sectionCount = 1;
        
    } else if ([sourceString isEqualToString:@"enterShortlist"]){
        [players addObject:[myGame.myData.myScouting getShortList]];
        sectionCount = 1;
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
    [myGame.source setObject:[[players objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] forKey:@"playerInfo"];
    PlayerInfoView* infoView = [[PlayerInfoView alloc]initWithTarget:target Player:[[players objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]];
    
    NSLog(@"remove from superview");
//    [infoView.contentView removeFromSuperview];
    NSLog(@"remove from superview");

    [target viewDidLoad];
//    [infoView.closeView addTarget:infoView.contentView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
//    [infoView.closeView.titleLabel setText:@"hihi"];
//    [target.view addSubview:infoView];
    //[infoView showInfoView:target Player:[[players objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]];
    /*
    PlayerInfoViewController *vc = [target.storyboard instantiateViewControllerWithIdentifier:@"enterInfo"];;
    [target presentViewController:vc animated:YES completion:nil];
    */
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Player* p = [[players objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([sourceString isEqualToString:@"enterPlayers"] || [sourceString isEqualToString:@"enterPreGame"]) {
        [myGame.myData.myLineup.currentTactic removePlayerFromTactic:p];
        PositionSide ps;
        [[myGame.source objectForKey:@"ps"] getValue:&ps];
        [myGame.myData.myLineup.currentTactic populatePlayer:p PositionSide:ps ForceSwap:NO];
        [myGame.myData.myLineup.currentTactic updatePlayerLineup];
        NSString* enterPlayersSource = [myGame.source objectForKey:@"enterPlayers"];
        if ([enterPlayersSource isEqualToString:@"enterTactic"]) {
            ViewController *vc = [target.storyboard instantiateViewControllerWithIdentifier:@"enterTactic"];;
            [target presentViewController:vc animated:YES completion:nil];
        } else if ([enterPlayersSource isEqualToString:@"enterPreGame"]) {
            ViewController *vc = [target.storyboard instantiateViewControllerWithIdentifier:@"enterPreGame"];;
            [target presentViewController:vc animated:YES completion:nil];

        }
    } else if ([sourceString  isEqualToString:@"enterPlan"]){
        Plan* thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:[[myGame.source objectForKey:@"PlanID"]integerValue]];
        [thisPlan.PlayerList removeObject:p];
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
        [((PlayersViewController*)target).playersView reloadData];
        [target viewDidLoad];
    }
}
@end
