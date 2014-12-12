//
//  ViewController.m
//  Game2
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "ViewController.h"
#import "GameModel.h"
#import "GlobalVariableModel.h"
#import "Match.h"
#import "LineUp.h"
#import "TacticView.h"

@interface ViewController ()

@end

@implementation ViewController
{
    GameModel* myGame;
}
- (void)viewDidLoad
{
    myGame = [GameModel myGame];
    [self getButtons];
    UILabel* time = (UILabel*)[self.view viewWithTag:620];
    time.font = [GlobalVariableModel newFont2Large];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) getButtons
{
    for (id subview in self.view.subviews) {
        if ([subview isKindOfClass:[TacticView class]]) {
            TacticView* t = (TacticView*) subview;
            t.target = self;
        }
        
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* l = (UILabel*) subview;
            if (l.tag == 201) {
                l.text = [NSString stringWithFormat:@"S%i W%i",myGame.myData.season,myGame.myData.week];
                l.font = [GlobalVariableModel newFont2Large];
            }
        }
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

}
- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"myGame.source - %@", myGame.source);
    
}

- (void) buttonAction:(UIButton*) sender
{
    NSLog(@"Button Press Tag %i",sender.tag);
    switch (sender.tag) {
        case 1001:
            [myGame newWithGameID:1];
            break;
        case 1002:
            [myGame loadWithGameID:1];
            [self goToView];
            break;
        case 1003:
            break;
        case 100:
            [myGame enterPreTask];
            break;
        case 211:
            myGame.myData.weekTask = TaskScout1;
            break;
        case 212:
            myGame.myData.weekTask = TaskScout2;
            break;
        case 213:
            myGame.myData.weekTask = TaskScout3;
            break;
        case 221:
            myGame.myData.weekTask = TaskTraining1;
            break;
        case 222:
            myGame.myData.weekTask = TaskTraining2;
            break;
        case 223:
            myGame.myData.weekTask = TaskTraining3;
            break;
        case 231:
            myGame.myData.weekTask = TaskAdmin1;
            break;
        case 232:
            myGame.myData.weekTask = TaskAdmin2;
            break;
        case 233:
            myGame.myData.weekTask = TaskAdmin3;
            break;
        case 200:
            //see shouldPerformSegue
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
            if (myGame.myData.nextMatch.isOver)
                [myGame enterPostGame];
            break;
        case 601:
            [self startMatch];
            break;
            
        case 602:
            if (myGame.myData.nextMatch.isPaused && !myGame.myData.nextMatch.isOver) {
                [myGame.myData.nextMatch resumeMatch];
                [self updateCommentaryBoxWith:@"Match Resumes!"];
            }
            break;
            
        case 603:
            if (!myGame.myData.nextMatch.isPaused && myGame.myData.nextMatch.matchMinute > 0)
                [myGame.myData.nextMatch pauseMatch];
            break;
            
        case 700:
            [myGame enterPreWeek];
            break;
        case 999:
            [myGame saveThisGame];
            break;
        case 1100:
            [myGame enterTactic];
            break;
        case 1200:
            [myGame enterTraining];
            break;
        case 1210:
        case 1211:
        case 1212:
        case 1213:
            myGame.source = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(sender.tag-1210),@"PlanID",@"enterPlan",@"source", nil];
            [myGame enterPlan];
            break;
        default:
            break;
    }
    
}
             
- (void) startMatch
{
    if (![myGame.myData.nextMatch startMatch])
        [NSException raise:@"Match Start Fail" format:@"Match Start Fail"];

    [self updateCommentaryBoxWith:@"Match Starts!"];

    //        [self performSelectorOnMainThread:@selector(updateCommentaryBoxWith:) withObject:nextLine waitUntilDone:NO];
//        [self performSelector:@selector(updateCommentaryBoxWith:) withObject:nextLine afterDelay:1000];

    
}

- (void) updateCommentaryBoxWith:(NSString*) commentary
{
    UILabel* box = (UILabel*)[self.view viewWithTag:610];
    box.font = [GlobalVariableModel newFont2Medium];
    box.text = commentary;
   
    NSString* nextLine = [[myGame.myData.nextMatch  nextMinute] componentsJoinedByString:@"\n"];
    
    UILabel* time = (UILabel*)[self.view viewWithTag:620];
    time.font = [GlobalVariableModel newFont2Large];
    time.text = [@(myGame.myData.nextMatch.matchMinute) stringValue];
    
    if (!myGame.myData.nextMatch.isOver && ! myGame.myData.nextMatch.isPaused)
        [self performSelector:@selector(updateCommentaryBoxWith:) withObject:nextLine afterDelay:.1];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    switch (((UIButton*)sender).tag) {
        case 500:
            if (![myGame.myData.myLineup validateTactic]) {
                NSLog(@"Invalid Tactic");
                return NO;
            }
            break;
        case 200:
            if (myGame.myData.weekTask == TaskNone)
                return NO;
            [myGame enterTask];
            break;
        default:
            break;
            
    }
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) goToView{
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:myGame.myData.weekStage];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
