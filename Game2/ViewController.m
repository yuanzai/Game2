//
//  ViewController.m
//  Game2
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "ViewController.h"
#import "TacticViewController.h"
#import "GameModel.h"
#import "GlobalVariableModel.h"
#import "Match.h"

@interface ViewController ()

@end

@implementation ViewController
{
    GameModel* myGame;
}
- (void)viewDidLoad
{
    myGame = [GameModel myGame];
    myGame.currentViewController = self;
    [self getButtons];

    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad");
}

- (void) getButtons
{
    for (id subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton* b = (UIButton*) subview;
            [b addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [[b titleLabel]setFont:[GlobalVariableModel newFont2Large]];
            [b invalidateIntrinsicContentSize];

        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"DisAppear");
}
- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Appear");
}

- (void) buttonAction:(UIButton*) sender
{
    NSLog(@"Button Press Tag %i",sender.tag);
 
/*
    TeamViewController *teamViewController = (TeamViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TeamView"];
    [self presentViewController:teamViewController animated:YES completion:nil];
*/
    switch (sender.tag) {
        case 1001:
            [myGame newWithGameID:1];
            break;
        case 1002:
            [myGame loadWithGameID:1];
            break;
        case 1003:
            break;
        case 100:
            [myGame enterPreTask];
            break;
        case 231:
        case 232:
        case 233:
        case 211:
        case 212:
        case 213:
        case 221:
        case 222:
        case 223:
            [myGame setTask:[@(sender.tag) stringValue]];
            break;
        case 200:
            [myGame enterTask];
            break;
        case 300:
            [myGame enterPostTask];
            break;
        case 400:
            [myGame enterPreGame];
            break;
        case 500:
            [myGame enterGame];
            break;
        case 600:
            [myGame enterPostGame];
            break;
        case 601:
            [self startMatch];
            break;
            
        case 602:
            [myGame enterPostGame];
            break;
            
        case 603:
            [myGame enterPostGame];
            break;
            
        case 700:
            [myGame enterPreWeek];
            break;
        case 1100:
            [myGame enterTacticFrom:[NSDictionary dictionaryWithObjectsAndKeys:@"enterTask",@"source", nil]];
            break;
        case 1200:
            [myGame enterTraining];
            break;
        case 1210:
        case 1211:
        case 1212:
        case 1213:

            [myGame enterPlanWith:[NSDictionary dictionaryWithObjectsAndKeys:@(sender.tag-1210),@"PlanID",@"enterPlan",@"source", nil]];
            break;
        default:
            break;
    }
    
}
             
- (void) startMatch
{
    UILabel* commentary = (UILabel*)[self.view viewWithTag:610];

    Match* playGame = myGame.myData.nextMatch;
    while (!playGame.isOver && !playGame.isPaused) {
        commentary.text = [[playGame nextMinute] componentsJoinedByString:@"\n"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
