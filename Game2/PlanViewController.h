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
@property NSInteger PlanID;
@property NSDictionary* source;
@property (strong,nonatomic) PlayerList *tableSource;

@end
