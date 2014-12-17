//
//  PlayerList.h
//  Game2
//
//  Created by Junyuan Lau on 26/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlayerList : NSObject <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain) UIViewController* target;
@property __block NSMutableArray* players;

- (id) initWithTarget:(UIViewController*) thisTarget;

@end
