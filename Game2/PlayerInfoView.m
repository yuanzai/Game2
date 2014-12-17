//
//  PlayerInfoView.m
//  Game2
//
//  Created by Junyuan Lau on 14/12/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "PlayerInfoView.h"
#import "Player.h"

@implementation PlayerInfoView
@synthesize player;
@synthesize target;
@synthesize closeView;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void) awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"PlayerInfoView"
                                   owner:self
                                 options:nil];
    [self.closeView.titleLabel setText:@"hihihi"];
    [self addSubview:self.contentView];
}



- (id) initWithTarget:(UIViewController*)source Player:(Player*)p
{
    self = [super init];
    if (self) {
        target = source;
        player = p;
        self.contentView  = [[[NSBundle mainBundle] loadNibNamed:@"PlayerInfoView"
                                                           owner:self
                                                         options:nil]firstObject];
        
        self.contentView.frame = target.view.frame;
        [closeView setTitle:@"Done" forState:UIControlStateNormal];
        [closeView addTarget:self.contentView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        [target.view addSubview:self.contentView];
        NSLog(@"%@",self);
    }
    return self;
}

- (void) closeInfoView:(UIButton*) sender
{
    [self.contentView removeFromSuperview];
}

@end
