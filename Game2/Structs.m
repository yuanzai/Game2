//
//  Structs.m
//  Game2
//
//  Created by Junyuan Lau on 9/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import "Structs.h"

@implementation Structs
+ (NSString*) getPositionString:(PositionSide) ps
{
    if (ps.position == GKPosition)
        return @"GK";
    if (ps.position == Def)
        return @"DEF";
    if (ps.position == DM)
        return @"DM";
    if (ps.position == Mid)
        return @"MID";
    if (ps.position == AM)
        return @"AM";
    if (ps.position == SC)
        return @"SC";
    return @"";
}

+ (NSString*) getSideString:(PositionSide) ps
{
    if (ps.side == Left)
        return @"LEFT";
    if (ps.side == LeftCentre)
        return @"LEFTCENTRE";
    if (ps.side == Centre)
        return @"CENTRE";
    if (ps.side == RightCentre)
        return @"RIGHTCENTRE";
    if (ps.side == Right)
        return @"RIGHT";
    if (ps.side == GKSide)
        return @"GK";
    return @"";
}
@end
