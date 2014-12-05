//
//  FixturesViewController.m
//  Game2
//
//  Created by Junyuan Lau on 5/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "FixturesViewController.h"
#import "GameModel.h"
#import "Fixture.h"
#import "Team.h"
@interface FixturesViewController ()

@end

@implementation FixturesViewController
@synthesize NextTeamName;
- (void)viewDidLoad {
    [super viewDidLoad];
    GameModel* myGame = [GameModel myGame];
    NextTeamName.font = [GlobalVariableModel newFont2Large];
    NextTeamName.lineBreakMode = NSLineBreakByWordWrapping;
    NextTeamName.textAlignment = NSTextAlignmentCenter;

    NextTeamName.text = [NSString stringWithFormat:@"%@\nv\n%@",[myGame.myGlobalVariableModel getTeamFromID:myGame.myData.nextFixture.HOMETEAM].Name,[myGame.myGlobalVariableModel getTeamFromID:myGame.myData.nextFixture.AWAYTEAM].Name];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
