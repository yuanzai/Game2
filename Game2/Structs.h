//
//  Structs.h
//  Game2
//
//  Created by Junyuan Lau on 9/11/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Left,
    LeftCentre,
    Centre,
    RightCentre,
    Right,
    GKSide,
    SideCount
} SideChoices;

typedef enum {
    Def,
    DM,
    Mid,
    AM,
    SC,
    GKPosition,
    PositionCount
} PositionChoices;

struct PositionSide {
    PositionChoices position;
    SideChoices side;
};

typedef struct PositionSide PositionSide;

typedef enum {
    GK,
    Own,
    Opp,
    Area,
    ZoneCount
} Zone;

typedef enum {
    GKFlank,
    LeftFlank,
    CentreFlank,
    RightFlank,
    FlankCount
} Flank;

struct ZoneFlank {
    Zone zone;
    Flank flank;
};

typedef struct ZoneFlank ZoneFlank;


@interface Structs : NSObject
+ (NSString*) getPositionString:(PositionSide) ps;
+ (NSString*) getSideString:(PositionSide) ps;
+ (PositionSide) getPositionSideFromTextWithPosition:(NSString*)position Side:(NSString*) side;
+ (PositionSide) getPositionSideFromDictionary:(NSDictionary*) record;


+ (NSString*) getZoneString:(ZoneFlank) zf;
+ (NSString*) getFlankString:(ZoneFlank) zf;
+ (ZoneFlank) getZoneFlankFromTextWithZone:(NSString*)zone Flank:(NSString*) flank;
+ (ZoneFlank) getZoneFlankFromDictionary:(NSDictionary*) record;

@end

