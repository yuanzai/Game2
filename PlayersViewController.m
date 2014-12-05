//
//  PlayersViewController.m
//  Game2
//
//  Created by Junyuan Lau on 22/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlayersViewController.h"
#import "GameModel.h"
#import "LineUp.h"
#import "PlayerInfoViewController.h"
#import "PlayerList.h"

@interface PlayersViewController ()

@end

@implementation PlayersViewController
{
    GameModel* myGame;
}
@synthesize tableSource;
- (void)viewDidLoad
{
    myGame = [GameModel myGame];

    UITableView* playersView = (UITableView*) [self.view viewWithTag:1];
    tableSource = [[PlayerList alloc]initWithTarget:self Source:myGame.source];
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
    myGame.currentViewController = self;
    [myGame saveThisGame];
    [myGame exitPlayers];
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

