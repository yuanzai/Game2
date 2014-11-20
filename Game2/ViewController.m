//
//  ViewController.m
//  Game2
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "ViewController.h"
#import "TeamViewController.h"
#import "GameModel.h"
@interface ViewController ()

@end

@implementation ViewController
{
    GameModel* myGame;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    myGame = [GameModel myGame];
    myGame.currentViewController = self;
    for (id subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]])
            [(UIButton*) subview addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) buttonAction:(UIButton*) sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
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
        case 700:
            [myGame enterPreWeek];
            break;
        
        default:
            break;
    }    
    NSLog(@"Button Press Tag %i",sender.tag);
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
