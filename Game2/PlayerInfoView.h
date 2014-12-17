//
//  PlayerInfoView.h
//  Game2
//
//  Created by Junyuan Lau on 14/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Player;
@interface PlayerInfoView : UIView

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *closeView;

@property (nonatomic, weak) UIViewController* target;
@property (nonatomic, weak) Player* player;

- (id) initWithTarget:(UIViewController*)source Player:(Player*)p;

- (void) closeInfoView:(UIButton*) sender;
@end
