//
//  ShortlistViewController.m
//  Game2
//
//  Created by Junyuan Lau on 14/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "ShortlistViewController.h"
#import "PlayerList.h"
#import "GameModel.h"

@interface ShortlistViewController ()

@end

@implementation ShortlistViewController{
    GameModel* myGame;
}
@synthesize playersView, tableSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myGame = [GameModel myGame];
    myGame.source = @{@"source" : @"enterShortlist"};
    tableSource = [[PlayerList alloc]initWithTarget:self];
    playersView.dataSource = tableSource;
    playersView.delegate = tableSource;

    
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
