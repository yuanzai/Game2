//
//  PlayersViewController.m
//  Game2
//
//  Created by Junyuan Lau on 22/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlayersViewController.h"
#import "GameModel.h"
#import "Player.h"
#import "Team.h"
#import "LineUp.h"
#import "Tactic.h"
#import "PlayerInfoViewController.h"
#import "PlayerList.h"

@interface PlayersViewController ()

@end

@implementation PlayersViewController
{
    GameModel* myGame;
}
@synthesize source;
@synthesize tableSource;
- (void)viewDidLoad
{
    UITableView* playersView = (UITableView*) [self.view viewWithTag:1];
    tableSource = [[PlayerList alloc]initWithTarget:self Source:source];
    playersView.delegate = tableSource;
    playersView.dataSource = tableSource;

    [super viewDidLoad];
    myGame = [GameModel myGame];
       UIButton* doneButton = (UIButton*) [self.view viewWithTag:999];
    [doneButton addTarget:self action:@selector(backTo:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton.titleLabel setFont:[GlobalVariableModel newFont2Large]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backTo:(UIButton*) sender
{
    [myGame exitPlayersTo:source];
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [[[[myGame myData]myTeam]PlayerList]count];
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
    cell.textLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:13.0];
    cell.textLabel.text = p.DisplayName;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"playerInfo"];
    vc.thisPlayer = [myGame.myData.myTeam.PlayerList objectAtIndex:indexPath.row];
    vc.source = self.source;
    [self presentViewController:vc animated:YES completion:nil];
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
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

