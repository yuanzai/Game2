//
//  PlanViewController.m
//  Game2
//
//  Created by Junyuan Lau on 25/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlanViewController.h"
#import "GameModel.h"
#import "GlobalVariableModel.h"
#import "Training.h"
#import "Player.h"
#import "PlayerList.h"
@interface PlanViewController ()

@end

@implementation PlanViewController
{
    GameModel* myGame;
    Plan* thisPlan;
    NSMutableArray* planStatButtons;
    NSArray* statArray;
}

@synthesize tableSource;
@synthesize playersView;

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
    
    /* 
     @"0",@"DRILLS",
     @"0",@"SHOOTING",
     @"0",@"PHYSICAL",
     @"0",@"TACTICS",
     @"0",@"SKILLS",
     @"1",@"INTENSITY", nil];
*/
    // Do any additional setup after loading the view.
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadData];
}

- (void) loadData
{
    myGame = [GameModel myGame];
    myGame.currentViewController = self;
    thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:[[myGame.source objectForKey:@"PlanID"]integerValue]];
    statArray = [GlobalVariableModel planStats];
    
    //    playersView = (UITableView*) [self.view viewWithTag:1];
    tableSource = [[PlayerList alloc]initWithTarget:self];
    playersView.delegate = tableSource;
    playersView.dataSource = tableSource;
    

    UILabel* playerCount = (UILabel*)[self.view viewWithTag:20];
    [playerCount setFont:[GlobalVariableModel newFont2Medium]];
    [playerCount setText:[NSString stringWithFormat:@" %i Players",[thisPlan.PlayerList count]]];

    
    UIButton* add = (UIButton*)[self.view viewWithTag:30];
    NSInteger unassignedCount = [[myGame.myData.myTraining getUnassignedPlayers]count];
    [add setTitle:[NSString stringWithFormat:@"Add players (%i)",unassignedCount] forState:UIControlStateNormal];
    [add.titleLabel setFont:[GlobalVariableModel newFont2Medium]];
    //[add invalidateIntrinsicContentSize];
    [add addTarget:self action:@selector(addPlayers:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* coach = (UIButton*)[self.view viewWithTag:100];
    [coach setTitle:thisPlan.thisCoach.COACHNAME forState:UIControlStateNormal];
    [coach.titleLabel setFont:[GlobalVariableModel newFont2Medium]];
    //[coach.titleLabel setFont:[GlobalVariableModel newFont2Large]];
    
    
    planStatButtons = [NSMutableArray array];
    for (NSInteger i = 0;i<5;i++) {
        UIButton* button = (UIButton*) [self.view viewWithTag:10 + i];
        NSString* stat = [statArray objectAtIndex:i];
        
        [button setTitle:[NSString stringWithFormat:@"%i",[[thisPlan.PlanStats objectForKey:stat] integerValue]] forState:UIControlStateNormal];
        //[button invalidateIntrinsicContentSize];
        [button.titleLabel setFont:[GlobalVariableModel newFont2Medium]];
        [button addTarget:self action:@selector(pressPlanStat:) forControlEvents:UIControlEventTouchUpInside];
        [planStatButtons addObject:button];
    }
    UIButton* back = (UIButton*)[self.view viewWithTag:999];
    [back addTarget:self action:@selector(backTo:) forControlEvents:UIControlEventTouchUpInside];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidDisappear:(BOOL)animated
{
    [myGame saveThisGame];
}

- (void) pressPlanStat:(UIButton*) sender {
    NSString* stat = [statArray objectAtIndex:sender.tag - 10];
    NSInteger currentStat = [[thisPlan.PlanStats objectForKey:stat]integerValue];
    
    if (currentStat == 2) {
        currentStat = -2;
    } else{
        currentStat++;
    }

    [thisPlan.PlanStats setObject:@(currentStat) forKey:stat];
    [sender setTitle:[@(currentStat) stringValue] forState:UIControlStateNormal];
}
- (void) addPlayers:(UIButton*) sender
{
    [myGame.source setObject:@"enterPlan" forKey:@"supersource"];
    [myGame.source setObject:@"enterPlanPlayers" forKey:@"source"];
    [myGame enterPlayers];
}

- (void) backTo:(UIButton*) sender
{
    [thisPlan updateTrainingPlanToDatabase];
    [myGame enterTraining];
}

- (void) refreshTable
{
    [self viewDidLoad];
    [self viewWillAppear:YES];
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
