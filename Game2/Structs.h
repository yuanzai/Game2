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

@interface Structs : NSObject
+ (NSString*) getPositionString:(PositionSide) ps;
+ (NSString*) getSideString:(PositionSide) ps;

@end

