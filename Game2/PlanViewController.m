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
@interface PlanViewController ()

@end

@implementation PlanViewController
{
    GameModel* myGame;
    Plan* thisPlan;
    NSMutableArray* planStatButtons;
}
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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myGame = [GameModel myGame];
    thisPlan = [myGame.myData.myTraining.Plans objectAtIndex:PlanID];
    
    
    UIButton* coach = (UIButton*)[self.view viewWithTag:1];
    [coach setTitle:[thisPlan.Coach objectForKey:@"NAME"] forState:UIControlStateNormal];
    [coach.titleLabel setFont:[GlobalVariableModel newFont2Large]];
    
    planStatButtons = [NSMutableArray array];
    
    for (NSInteger i = 0;i<5;i++) {
        UIButton* button = (UIButton*) [self.view viewWithTag:10 + i];
        button.titleLabel.text = [thisPlan.PlanStats objectForKey:[[thisPlan.PlanStats allKeys]objectAtIndex:i]];
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
    NSInteger currentStat = [[thisPlan.PlanStats objectForKey:[[thisPlan.PlanStats allKeys]objectAtIndex:sender.tag - 10]]integerValue];
    
    currentStat = currentStat == 2 ? -2 : currentStat ++;
    [thisPlan.PlanStats setObject:@(currentStat) forKey:[[thisPlan.PlanStats allKeys]objectAtIndex:sender.tag - 10]];
    sender.titleLabel.text = [thisPlan.PlanStats objectForKey:[[thisPlan.PlanStats allKeys]objectAtIndex:sender.tag-10]];
}

- (void) backTo:(UIButton*) sender
{
    [thisPlan updateTrainingPlanToDatabase];
    [myGame enterTraining];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [thisPlan.Players count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 100) {
        static NSString *MyIdentifier = @"trainingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:MyIdentifier];
        }
        Player* p = (Player*) [thisPlan.Players objectAtIndex:indexPath.row];
        cell.textLabel.font = [GlobalVariableModel newFont2Medium];
        cell.textLabel.text = p.LastName;
        return cell;
    }
    
    return nil;
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
