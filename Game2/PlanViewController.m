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
@synthesize source;
@synthesize PlanID;

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
    PlanID = [[source objectForKey:@"PlanID"]integerValue];
    myGame = [GameModel myGame];
    thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:PlanID];
    statArray = [GlobalVariableModel planStats];
    
    UITableView* playersView = (UITableView*) [self.view viewWithTag:1];
    tableSource = [[PlayerList alloc]initWithTarget:self Source:source];
    playersView.delegate = tableSource;
    playersView.dataSource = tableSource;

    
    UIButton* coach = (UIButton*)[self.view viewWithTag:100];
    [coach setTitle:[thisPlan.Coach objectForKey:@"NAME"] forState:UIControlStateNormal];
    //[coach.titleLabel setFont:[GlobalVariableModel newFont2Large]];
    
    planStatButtons = [NSMutableArray array];
    for (NSInteger i = 0;i<5;i++) {
        UIButton* button = (UIButton*) [self.view viewWithTag:10 + i];
        NSString* stat = [statArray objectAtIndex:i];
        
        [button setTitle:[NSString stringWithFormat:@"%i",[[thisPlan.PlanStats objectForKey:stat] integerValue]] forState:UIControlStateNormal];
        [button invalidateIntrinsicContentSize];
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

- (void) backTo:(UIButton*) sender
{
    [thisPlan updateTrainingPlanToDatabase];
    [myGame enterTraining];
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
