//
//  LeagueTableViewController.h
//  Game2
//
//  Created by Junyuan Lau on 6/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LeagueTableCell: UITableViewCell
@property (nonatomic) IBOutlet UILabel* pos;
@property (nonatomic) IBOutlet UILabel* team;
@property (nonatomic) IBOutlet UILabel* p;
@property (nonatomic) IBOutlet UILabel* w;
@property (nonatomic) IBOutlet UILabel* l;
@property (nonatomic) IBOutlet UILabel* d;
@property (nonatomic) IBOutlet UILabel* gf;
@property (nonatomic) IBOutlet UILabel* ga;
@property (nonatomic) IBOutlet UILabel* gd;
@property (nonatomic) IBOutlet UILabel* pt;

@end

@interface LeagueTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong,nonatomic) IBOutlet UITableView* leagueTableView;

@end

