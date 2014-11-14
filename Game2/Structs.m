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

+ (PositionSide) getPositionSideFromTextWithPosition:(NSString*)position Side:(NSString*) side
{
    PositionSide retPositionSide;
    
    if ([[position uppercaseString] isEqualToString:@"DEF"]) {
        retPositionSide.position = Def;
    } else if (([[position uppercaseString] isEqualToString:@"DM"])) {
        retPositionSide.position = DM;
    } else if ([[position uppercaseString] isEqualToString:@"MID"]) {
        retPositionSide.position  = Mid;
    } else if ([[position uppercaseString] isEqualToString:@"AM"]) {
        retPositionSide.position  = AM;
    } else if ([[position uppercaseString] isEqualToString:@"SC"]) {
        retPositionSide.position  = SC;
    } else if ([[position uppercaseString] isEqualToString:@"GK"]) {
        retPositionSide.position  = GKPosition;
    }
    
    if ([[side uppercaseString] isEqualToString:@"LEFT"]) {
        retPositionSide.side = Left;
    } else if (([[side uppercaseString] isEqualToString:@"LEFTCENTRE"])) {
        retPositionSide.side = LeftCentre;
    } else if ([[side uppercaseString] isEqualToString:@"CENTRE"]) {
        retPositionSide.side = Centre;
    } else if ([[side uppercaseString] isEqualToString:@"RIGHTCENTRE"]) {
        retPositionSide.side = RightCentre;
    } else if ([[side uppercaseString] isEqualToString:@"RIGHT"]) {
        retPositionSide.side = Right;
    } else if ([[side uppercaseString] isEqualToString:@"GK"]) {
        retPositionSide.side = GKSide;
    }
    return retPositionSide;
}

+ (ZoneFlank) getZoneFlankFromTextWithZone:(NSString*)zone Flank:(NSString*) flank
{
    ZoneFlank retZoneFlank;
    if ([[flank uppercaseString] isEqualToString:@"LEFT"]) {
        retZoneFlank.flank = LeftFlank;
    } else if (([[flank uppercaseString] isEqualToString:@"CENTRE"])) {
        retZoneFlank.flank = CentreFlank;
    } else if ([[flank uppercaseString] isEqualToString:@"RIGHT"]) {
        retZoneFlank.flank = RightFlank;
    } else if ([[flank uppercaseString] isEqualToString:@"GK"]) {
        retZoneFlank.flank = GKFlank;
    }
    
    if ([[zone uppercaseString] isEqualToString:@"OWN"]) {
        retZoneFlank.zone = Own;
    } else if (([[zone uppercaseString] isEqualToString:@"OPP"])) {
        retZoneFlank.zone = Opp;
    } else if ([[zone uppercaseString] isEqualToString:@"AREA"]) {
        retZoneFlank.zone = Area;
    } else if ([[zone uppercaseString] isEqualToString:@"GK"]) {
        retZoneFlank.zone = GK;
    }
    return retZoneFlank;
}

+ (NSString*) getZoneString:(ZoneFlank) zf
{
    if (zf.zone == Own)
        return @"Own";
    if (zf.zone == Opp)
        return @"Opp";
    if (zf.zone == Area)
        return @"Area";
    if (zf.zone == GK)
        return @"GK";
    return @"";
}

+ (NSString*) getFlankString:(ZoneFlank) zf
{
    if (zf.flank == LeftFlank)
        return @"Left";
    if (zf.flank == CentreFlank)
        return @"Centre";
    if (zf.flank == RightFlank)
        return @"Right";
    if (zf.flank == GKFlank)
        return @"GK";
    return @"";
}

+ (PositionSide) getPositionSideFromDictionary:(NSDictionary*) record
{
    return [Structs getPositionSideFromTextWithPosition:[record objectForKey:@"OUTPOSITION"] Side:[record objectForKey:@"OUTSIDE"]];
}

+ (ZoneFlank) getZoneFlankFromDictionary:(NSDictionary*) record
{
    return [Structs getZoneFlankFromTextWithZone:[record objectForKey:@"OUTZONE"] Flank:[record objectForKey:@"OUTFLANK"]];
}

@end
