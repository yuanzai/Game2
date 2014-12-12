//
//  ScoutsViewController.m
//  Game2
//
//  Created by Junyuan Lau on 10/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "ScoutsViewController.h"
#import "Scouting.h"
#import "GameModel.h"
@interface ScoutsViewController ()

@end

@implementation ScoutsViewController
{
    GameModel* myGame;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myGame = [GameModel myGame];
    for (UIView* v in self.view.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton* b = (UIButton*) v;
            if (b.tag < 40) {
                Scout* thisScout = [myGame.myData.myScouting.scoutArray objectAtIndex:b.tag/10];
                if (b.tag % 10 == 3){
                    [b setTitle:[thisScout getStringForScoutType:thisScout.SCOUTTYPE]  forState:UIControlStateNormal];
                } else if (b.tag % 10 == 4){
                    [b setTitle:[thisScout getStringForScoutPosition:thisScout.SCOUTPOSITION]  forState:UIControlStateNormal];
                } else if (b.tag % 10 == 1){
                    [b setTitle:thisScout.NAME forState:UIControlStateNormal];
                }
                [b addTarget:self action:@selector(onTouch:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [myGame saveThisGame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onTouch:(UIButton*) sender
{
    Scout* thisScout = [myGame.myData.myScouting.scoutArray objectAtIndex:sender.tag/10];
    if (sender.tag % 10 == 3){
        if (thisScout.SCOUTTYPE == 2) {
            thisScout.SCOUTTYPE = (ScoutTypes) {0};
        } else {
            thisScout.SCOUTTYPE = (ScoutTypes) {thisScout.SCOUTTYPE + 1};
        }

        [sender setTitle:[thisScout getStringForScoutType:thisScout.SCOUTTYPE]  forState:UIControlStateNormal];
        //sender.titleLabel.text = [thisScout getStringForScoutType:thisScout.SCOUTTYPE];
    } else if (sender.tag % 10 == 4){
        if (thisScout.SCOUTPOSITION == 4) {
            thisScout.SCOUTPOSITION = (ScoutPosition) {0};
        } else {
            thisScout.SCOUTPOSITION = (ScoutPosition) {thisScout.SCOUTPOSITION + 1};
        }
        [sender setTitle:[thisScout getStringForScoutPosition:thisScout.SCOUTPOSITION]  forState:UIControlStateNormal];
    } else if (sender.tag % 10 == 1){
    }
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
