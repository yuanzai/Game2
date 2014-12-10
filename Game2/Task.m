//
//  Task.m
//  Game2
//
//  Created by Junyuan Lau on 9/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "Task.h"
#import "GameModel.h"
#import "Scouting.h"
#import "Training.h"
#import "Team.h"

@implementation Task
{
    WeekTask thisTask;
    GameModel* myGame;
}

- (id) init
{
    self = [super init];
    if (self) {
        myGame = [GameModel myGame];
        thisTask = myGame.myData.weekTask;
    }; return self;
}

- (void) runTask
{
    if (thisTask == TaskScout1 || thisTask == TaskScout2 || thisTask == TaskScout3){
        [self runScoutTask];
    } else if (thisTask == TaskTraining1 || thisTask == TaskTraining2 || thisTask == TaskTraining3){
        [self runTrainingTask];
    } else if (thisTask == TaskAdmin1 || thisTask == TaskAdmin2 || thisTask == TaskAdmin3){
    }
}

- (void) runScoutTask
{
    __block NSInteger topJudgement = 0;
    __block NSInteger topYouth = 0;
    [[[[GameModel myGame]myScouting]scoutArray]enumerateObjectsUsingBlock:^(Scout* s, NSUInteger idx, BOOL *stop) {
        if (s.JUDGEMENT > topJudgement)
            topJudgement = s.JUDGEMENT;
        if (s.YOUTH > topYouth)
            topYouth = s.YOUTH;
    }];
    Scout* spScout = [[Scout alloc]init];
    NSMutableArray* resultArray = [NSMutableArray array];
    
    switch (thisTask) {
        case TaskScout1:
            spScout.SCOUTPOSITION = ScoutAny;
            spScout.SCOUTTYPE = SquadPlayer;
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            break;
            
        case TaskScout2:
            spScout.SCOUTPOSITION = ScoutAny;
            spScout.SCOUTTYPE = StarPlayer;
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            break;

        case TaskScout3:
            spScout.SCOUTPOSITION = ScoutAny;
            spScout.SCOUTTYPE = Youth;
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            [resultArray addObjectsFromArray:[spScout getScoutingPlayerArray]];
            break;
        case TaskTraining1:

        
        default:
            break;
    }
}

- (void) runTrainingTask
{
    __block Coach* newCoach = [[Coach alloc]init];
    [myGame.myData.myTraining.Plans enumerateObjectsUsingBlock:^(Plan* pl, NSUInteger idx, BOOL *stop) {
        [pl.thisCoach.valueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[pl.thisCoach valueForKey:obj]integerValue] > [[newCoach valueForKey:obj]integerValue])
                [newCoach setValue:@([[pl.thisCoach valueForKey:obj]integerValue]) forKey:obj];
        }];
    }];
    NSMutableDictionary *data = myGame.myData.taskData;
    Plan* newPlan;
    if (thisTask == TaskTraining1) {
        newPlan = [[Plan alloc]initWithCoach:newCoach PlayerList:myGame.myData.myTeam.PlayerList StatsGroup:nil];
        [newPlan runTrainingPlan];
        
    } else if (thisTask == TaskTraining2) {
        if ([data objectForKey:@"player"] && [data objectForKey:@"groupstat"]) {
            newPlan = [[Plan alloc]initWithCoach:newCoach PlayerList:[NSArray arrayWithObjects:[data objectForKey:@"player"], nil] StatsGroup:[data objectForKey:@"groupstat"]];
            for (int i = 0; i < 5; i++) {
                [newPlan runTrainingPlan];
            }
        }
    } else if (thisTask == TaskTraining3) {
        NSInteger boostCount = [myGame.myData.myTeam.PlayerList count]/2;
        NSMutableArray* playerBoostArray = [NSMutableArray arrayWithArray:myGame.myData.myTeam.PlayerList];
        playerBoostArray = [GlobalVariableModel shuffleArray:playerBoostArray];
        for (NSInteger i = 0; i < boostCount; i++) {
            [playerBoostArray removeObjectAtIndex:i];
        }
        
    }    
}

- (void) runAdminTask
{
    if (thisTask == TaskAdmin1) {
        
    } else if (thisTask == TaskAdmin2) {
    } else if (thisTask == TaskAdmin3) {
    }
}

@end
