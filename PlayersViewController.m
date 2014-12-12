//
//  PlayersViewController.m
//  Game2
//
//  Created by Junyuan Lau on 22/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlayersViewController.h"
#import "GameModel.h"
#import "PlayerInfoViewController.h"
#import "PlayerList.h"

#import "ViewController.h"
#import "PlanViewController.h"

@interface PlayersViewController ()

@end

@implementation PlayersViewController
{
    GameModel* myGame;
}
@synthesize tableSource;
@synthesize playersView;
- (void)viewDidLoad
{
    myGame = [GameModel myGame];
    [myGame.source setObject:[myGame.source objectForKey:@"source"] forKey:@"enterPlayers"];
    [myGame.source setObject:@"enterPlayers" forKey:@"source"];
    tableSource = [[PlayerList alloc]initWithTarget:self];
    playersView.delegate = tableSource;
    playersView.dataSource = tableSource;

    [super viewDidLoad];
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
    NSString* enterPlayersSource = [myGame.source objectForKey:@"enterPlayers"];
    if ([enterPlayersSource isEqualToString:@"enterTactic"] || [enterPlayersSource isEqualToString:@"enterPreGame"]) {
        ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:enterPlayersSource];
        [self presentViewController:vc animated:YES completion:nil];

    } else if ([enterPlayersSource isEqualToString:@"enterPlan"]){
        PlanViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:enterPlayersSource];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [myGame saveThisGame];
}
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

