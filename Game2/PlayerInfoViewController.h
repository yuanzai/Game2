//
//  PlayerInfoViewController.h
//  Game2
//
//  Created by Junyuan Lau on 22/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Structs.h"
@class Player;
@class PlayersViewController;
@interface PlayerInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property Player* thisPlayer;
@property PositionSide tacticPS;
@end
