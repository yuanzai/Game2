//
//  PlanViewController.h
//  Game2
//
//  Created by Junyuan Lau on 25/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayerList;
@interface PlanViewController : UIViewController
@property (strong,nonatomic) PlayerList *tableSource;
@property (strong,nonatomic) IBOutlet UITableView* playersView;
- (void) refreshTable;

@end
