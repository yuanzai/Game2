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
@property(nonatomic,retain) id target;
@property NSMutableArray* players;
@property NSString* viewSource;

- (id) initWithTarget:(id) thisTarget Source:(NSDictionary*) thisSource;
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
