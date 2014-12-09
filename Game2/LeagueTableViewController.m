//
//  LeagueTableViewController.m
//  Game2
//
//  Created by Junyuan Lau on 6/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "LeagueTableViewController.h"
#import "GameModel.h"
#import "Fixture.h"

@implementation LeagueTableCell
@synthesize pos,team,w,l,d,ga,gd,gf,pt,p;
@end



@interface LeagueTableViewController ()

@end

@implementation LeagueTableViewController
{
    GameModel* myGame;
}
@synthesize leagueTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    myGame = [GameModel myGame];
    //[self.leagueTableView registerClass:[LeagueTableCell class] forCellReuseIdentifier:@"LeagueTableRow"];

    //leagueTableView = (UITableView*) [self.view viewWithTag:1410];
    leagueTableView.delegate = self;
    leagueTableView.dataSource = self;
    if (!myGame.myData.currentLeagueTournament.currentLeagueTable)
        [NSException raise:@"No League Table" format:@"No League Table"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myGame.myData.currentLeagueTournament.currentLeagueTable count] + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"LeagueTableRow";
    LeagueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[LeagueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    cell.pt.textAlignment = NSTextAlignmentRight;
    if (indexPath.row == 0)
        return cell;
    
    
    NSDictionary* row = myGame.myData.currentLeagueTournament.currentLeagueTable[indexPath.row - 1];
    NSLog(@"row %@",row);
    Team* thisTeam = [myGame.myGlobalVariableModel.teamList objectForKey:[[row objectForKey:@"TEAM"]stringValue]];
    
    cell.team.font = [GlobalVariableModel newFont2Small];
    cell.pos.text = [@(indexPath.row) stringValue];
    cell.team.text = thisTeam.Name;
    
    cell.pt.text = [[row objectForKey:@"POINTS"]stringValue];
    return cell;
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
