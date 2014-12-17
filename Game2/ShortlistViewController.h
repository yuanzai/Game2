//
//  ShortlistViewController.h
//  Game2
//
//  Created by Junyuan Lau on 14/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayerList;
@interface ShortlistViewController : UIViewController
@property (strong,nonatomic) IBOutlet UITableView* playersView;
@property (strong,nonatomic) PlayerList *tableSource;

@end
