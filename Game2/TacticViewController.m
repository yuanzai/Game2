//
//  TacticViewController.m
//  Game2
//
//  Created by Junyuan Lau on 20/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "TacticViewController.h"
#import "GameModel.h"
#import "LineUp.h"
#import "Structs.h"

@interface TacticViewController ()

@end

@implementation TacticViewController
{
    GameModel* myGame;
    UIView* grid[5][5];
    CGPoint lastTouch;
    BOOL isDragged;
}
@synthesize source;

const NSInteger playerWidth = 50;
const NSInteger playerHeight = 50;

const NSInteger playerSpacing = 10;


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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isDragged = NO;
    myGame = [GameModel myGame];
    if (!myGame.myData.currentLineup.currentTactic)
        myGame.myData.currentLineup.currentTactic = [[Tactic alloc]initWithTacticID:1];

    [self createGrid];
    [self populateGridWithTactic:myGame.myData.currentLineup.currentTactic];

    for (id subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton* b = (UIButton*) subview;
            if (b.tag > 1100 && b.tag < 1200) {
                [b addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
                [b addTarget:self action:@selector(wasTouched:) forControlEvents:UIControlEventTouchDown];
                [b addTarget:self action:@selector(wasTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
                
            } else if (b.tag == 999) {
                [b addTarget:self action:@selector(backTo:) forControlEvents:UIControlEventTouchDown];
            }
        }
    }
}

- (void) backTo:(UIButton*) button
{
    [myGame exitTacticTo:source];
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
                Player* p = [tactic getPlayerAtPositionSide:ps];
                UIButton* playerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                playerButton.tag = i*10 + j;
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
                
                [self.view addSubview:playerButton];
            }
        }
    }
}

- (void) createGrid
{
    for (int i = 0; i < 5; i ++) {
        for (int j = 0; j < 5; j ++) {
            if (i==4 && (j == 0 || j == 4)) {
                continue;
            }
            
            UIView* v = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 4*playerSpacing - 5*playerWidth)/2 + j*(playerWidth+playerSpacing), 350- i*(playerHeight+playerSpacing),playerWidth,playerHeight)];
            v.layer.borderColor = [UIColor lightGrayColor].CGColor;
            v.layer.borderWidth = 1.0f;
            [self.view addSubview:v];
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
                    toRevert = NO;
                }
            }
        }
        if (toRevert)
            button.center = lastTouch;
    } else {

        PositionSide ps = {button.tag/10,button.tag%10};
        NSMutableDictionary* toSource = [NSMutableDictionary dictionary];
        [toSource setObject:[NSValue value:&ps withObjCType:@encode(PositionSide) ] forKey:@"ps"];
        [toSource setObject:@"enterTactic" forKey:@"source"];
        [toSource setObject:source forKey:@"supersource"];

        [myGame enterPlayersFrom:toSource];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
