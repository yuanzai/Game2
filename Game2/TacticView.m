//
//  TacticView.m
//  Game2
//
//  Created by Junyuan Lau on 3/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "TacticView.h"
#import "GameModel.h"
#import "LineUp.h"
#import "PlayersViewController.h"

@implementation TacticView
{
    GameModel* myGame;
    UIView* grid[5][5];
    CGPoint lastTouch;
    BOOL isDragged;
    Tactic* currentTactic;
}
@synthesize target;

const NSInteger playerWidth = 50;
const NSInteger playerHeight = 50;
const NSInteger playerSpacing = 10;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        isDragged = NO;
        myGame = [GameModel myGame];
        if (!myGame.myData.myLineup.currentTactic)
            myGame.myData.myLineup.currentTactic = [[Tactic alloc]initWithTacticID:0 WithPlayerDict:myGame.myData.lineUpPlayers];
        
        [self createGrid];
        currentTactic = myGame.myData.myLineup.currentTactic;
        [self populateGridWithTactic:currentTactic];
        for (id subview in self.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton* b = (UIButton*) subview;
                if (b.tag > 1100 && b.tag < 1200) {
                    [b addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
                    [b addTarget:self action:@selector(wasTouched:) forControlEvents:UIControlEventTouchDown];
                    [b addTarget:self action:@selector(wasTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }; return self;
}

- (void) wasTouched:(UIButton*) button
{
    isDragged = NO;
    lastTouch = button.center;
}

- (void) populateGridWithTactic:(Tactic*) tactic
{
    for (int i = 0; i < 5; i ++) {
        for (int j = 0; j < 5; j ++) {
            if (i==4 && (j == 0 || j == 4)) {
                continue;
            }
            PositionSide ps = {i,j};
            
            if ([tactic hasPositionAtPositionSide:ps]){
                NSInteger tagNo = [tactic getTacticPositionAtPositionSide:ps].PositionID;
                Player* p = [tactic getPlayerAtPositionSide:ps];
                UIButton* playerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                playerButton.tag = tagNo;
                playerButton.frame = CGRectMake(grid[i][j].center.x, grid[i][j].center.y, playerWidth, playerHeight);
                playerButton.center = grid[i][j].center;
                [playerButton setBackgroundColor:[UIColor greenColor]];
                [playerButton setTitle:p.DisplayName forState:UIControlStateNormal];
                
                playerButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                playerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                
                
                [playerButton.titleLabel setFont:[GlobalVariableModel newFont2Small]];
                [playerButton addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
                [playerButton addTarget:self action:@selector(wasTouched:) forControlEvents:UIControlEventTouchDown];
                [playerButton addTarget:self action:@selector(wasTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
                
                [self addSubview:playerButton];
            }
        }
    }
    UIButton* playerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playerButton.tag = 11;
    playerButton.frame = CGRectMake((self.frame.size.width - 4*playerSpacing - 5*playerWidth)/2 + 2*(playerWidth+playerSpacing), self.frame.size.height- (2) *(playerHeight+playerSpacing),playerWidth,playerHeight);
    [playerButton setBackgroundColor:[UIColor greenColor]];
    [playerButton setTitle:tactic.GoalKeeper.DisplayName forState:UIControlStateNormal];
    
    playerButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    playerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [playerButton.titleLabel setFont:[GlobalVariableModel newFont2Small]];
    [playerButton addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [playerButton addTarget:self action:@selector(wasTouched:) forControlEvents:UIControlEventTouchDown];
    [playerButton addTarget:self action:@selector(wasTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:playerButton];

}

- (void) createGrid
{
    for (int i = 0; i < 5; i ++) {
        for (int j = 0; j < 5; j ++) {
            if (i==4 && (j == 0 || j == 4)) {
                continue;
            }
            
            UIView* v = [[UIView alloc]initWithFrame:CGRectMake((self.frame.size.width - 4*playerSpacing - 5*playerWidth)/2 + j*(playerWidth+playerSpacing), self.frame.size.height- (i+3) *(playerHeight+playerSpacing),playerWidth,playerHeight)];
            v.layer.borderColor = [UIColor lightGrayColor].CGColor;
            v.layer.borderWidth = 1.0f;
            [self addSubview:v];
            grid[i][j] = v;
        }
    }
}

- (void)wasDraggedOut:(UIButton *)button withEvent:(UIEvent *)event
{
    NSLog(@"Tactic Position Dragged Out");
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    isDragged = YES;
    // get the touch
    UITouch *touch = [[event touchesForView:button] anyObject];
    
    // get delta
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;
    
    button.center = CGPointMake(button.center.x + delta_x,
                                button.center.y + delta_y);
}

- (void) wasTouchedUp: (UIButton*) button
{
    if (isDragged) {
        BOOL toRevert = YES;
        for (int i = 0; i < 5; i ++) {
            for (int j = 0; j < 5; j ++) {
                if (i==4 && (j == 0 || j == 4))
                    continue;
                if (CGRectContainsPoint(grid[i][j].frame, button.center)) {
                    button.center = grid[i][j].center;
                    TacticPosition* tp = [currentTactic.positionArray objectAtIndex:button.tag];
                    [currentTactic moveTacticPositionAtPositionSide:tp.ps ToPositionSide:(PositionSide) {i,j}];
                    toRevert = NO;
                }
            }
        }
        if (toRevert)
            button.center = lastTouch;
        [currentTactic updateTacticsInDatabase];
    } else {
        PositionSide ps;
        if (button.tag == 11) {
            ps.position = GKPosition;
            ps.side = GKSide;
        } else {
            TacticPosition* tp = [currentTactic.positionArray objectAtIndex:button.tag];
            ps = tp.ps;
        }
        myGame.source = [NSMutableDictionary dictionary];
        [myGame.source setObject:[NSValue value:&ps withObjCType:@encode(PositionSide) ] forKey:@"ps"];

        if (self.tag == 510) { // ie from tactic view
            [myGame.source setObject:@"enterTactic" forKey:@"source"];
        } else if (self.tag == 511) { //ie from pre match view
            [myGame.source setObject:@"enterPreGame" forKey:@"source"];
        }

        PlayersViewController *vc = [target.storyboard instantiateViewControllerWithIdentifier:@"enterPlayers"];
        [target presentViewController:vc animated:YES completion:nil];
    }
}
@end
