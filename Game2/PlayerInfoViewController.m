//
//  PlayerInfoViewController.m
//  Game2
//
//  Created by Junyuan Lau on 22/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlayerInfoViewController.h"
#import "Player.h"
#import "GlobalVariableModel.h"
#import "GameModel.h"

@interface PlayerInfoViewController ()

@end

@implementation PlayerInfoViewController
{
    NSMutableDictionary* infoDict;
    NSMutableDictionary* playerDetails;
    GameModel* myGame;
    
}
@synthesize thisPlayer;
@synthesize tacticPS;
@synthesize source;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myGame = [GameModel myGame];
    UIButton* doneButton = (UIButton*)[self.view viewWithTag:999];
    [doneButton addTarget:self action:@selector(backTo:) forControlEvents:UIControlEventTouchDown];
    
    UITableView* infoTable = (UITableView*)[self.view viewWithTag:1288];
    infoTable.delegate = self;
    infoTable.dataSource = self;
    playerDetails = [NSMutableDictionary dictionary];
    [playerDetails setObject:[NSString stringWithFormat:@"%@ %@",thisPlayer.FirstName, thisPlayer.LastName] forKey:@"Name"];
    NSString* positionString;
    NSString* DefString = @"";
    NSString* MidString = @"";
    NSString* AttString = @"";

    if ([[thisPlayer.PreferredPosition objectForKey:@"GK"]integerValue]==1) {
        positionString = @"Goalkeeper";
    } else {
        
        if ([[thisPlayer.PreferredPosition objectForKey:@"DEF"]integerValue]==1) {
            DefString = @"Def";
        }
        if ([[thisPlayer.PreferredPosition objectForKey:@"SC"]integerValue]==1) {
            AttString = @"Str";
        }
        
        if ([[thisPlayer.PreferredPosition objectForKey:@"DM"]integerValue]==1) {
            MidString = @"D Mid";
            if ([[thisPlayer.PreferredPosition objectForKey:@"AM"]integerValue]==1) {
                MidString = @"Mid";
            }
        }
        if ([[thisPlayer.PreferredPosition objectForKey:@"MID"]integerValue]==1) {
            MidString = @"Mid";
        }
        
        if ([[thisPlayer.PreferredPosition objectForKey:@"AM"]integerValue]==1) {
            MidString = @"A Mid";
        }
        
        NSArray* posArray = [[NSArray alloc]initWithObjects:DefString,MidString,AttString, nil];
        positionString = [posArray componentsJoinedByString:@"|"];
    }
    [playerDetails setObject:positionString forKey:@"Position"];

    NSMutableArray* sideArray = [NSMutableArray array];
    if ([[thisPlayer.PreferredPosition objectForKey:@"LEFT"]integerValue]==1)
        [sideArray addObject:@"LEFT"];
    if ([[thisPlayer.PreferredPosition objectForKey:@"CENTRE"]integerValue]==1)
        [sideArray addObject:@"CENTRE"];
    if ([[thisPlayer.PreferredPosition objectForKey:@"RIGHT"]integerValue]==1)
        [sideArray addObject:@"RIGHT"];

    NSString* SideString = [sideArray componentsJoinedByString:@"|"];
    [playerDetails setObject:SideString forKey:@"Flank"];

    UITableView* statTable = (UITableView*)[self.view viewWithTag:1299];
    statTable.delegate = self;
    statTable.dataSource = self;
    infoDict = [NSMutableDictionary dictionary];
    [infoDict addEntriesFromDictionary:thisPlayer.Stats];
    
    
    [infoDict setObject:thisPlayer.DisplayName forKey:@"DisplayName"];
    [infoDict setObject:thisPlayer.FirstName forKey:@"FirstName"];
    [infoDict setObject:thisPlayer.LastName forKey:@"LastName"];
    [infoDict setObject:@(thisPlayer.BirthYear) forKey:@"BirthYear"];
    
    
}

- (void) backTo:(UIButton*) button
{
    myGame.currentViewController = self;
    [myGame enterPlayersFrom:source];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1299) {
        return [infoDict count];
    } else if (tableView.tag == 1288) {
        return [playerDetails count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 1299) {
        static NSString *MyIdentifier = @"statCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:MyIdentifier];
        }
        cell.textLabel.font = [GlobalVariableModel newFont2Medium];
        cell.textLabel.text = [[infoDict allKeys]objectAtIndex:indexPath.row];
        NSLog(@"%@",[[infoDict allKeys]objectAtIndex:indexPath.row]);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",[[infoDict objectForKey:cell.textLabel.text]integerValue]];
        return cell;
    } else if (tableView.tag == 1288) {
        if ([[playerDetails allKeys]objectAtIndex:indexPath.row]) {
            static NSString *MyIdentifier = @"infoCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:MyIdentifier];
            }
            cell.textLabel.font = [GlobalVariableModel newFont2Medium];
            cell.textLabel.text = [[playerDetails allKeys]objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [playerDetails objectForKey:[[playerDetails allKeys]objectAtIndex:indexPath.row]];
            return cell;
        }
        return nil;
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
