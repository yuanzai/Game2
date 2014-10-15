//
//  SinglePlayerData.m
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "SinglePlayerData.h"
#import "Team.h"
@implementation SinglePlayerData
@synthesize SaveGameID;
@synthesize myTeam;
@synthesize nextMatch;

@synthesize weekdate;
@synthesize week;
@synthesize season;
@synthesize money;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.weekdate = [decoder decodeIntegerForKey:@"weekdate"];
    self.week = [decoder decodeIntegerForKey:@"week"];
    self.season = [decoder decodeIntegerForKey:@"season"];
    self.money = [decoder decodeIntegerForKey:@"money"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.weekdate forKey:@"weekdate"];
    [encoder encodeInteger:self.week forKey:@"week"];
    [encoder encodeInteger:self.season forKey:@"season"];
    [encoder encodeInteger:self.money forKey:@"money"];
}

@end
