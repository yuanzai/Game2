//
//  PlayersViewController.h
//  Game2
//
//  Created by Junyuan Lau on 22/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Structs.h"

@class  PlayerList;

@interface PlayersViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property NSDictionary* source;
@property (strong,nonatomic) PlayerList *tableSource;

@end
