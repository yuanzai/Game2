//
//  Scouting.m
//  MatchEngine
//
//  Created by Junyuan Lau on 1/10/14.
//  Copyright (c) 2014 Junyuan Lau. All rights reserved.
//

#import "Scouting.h"
#import "DatabaseModel.h"

@implementation Scouting
- (NSArray*) getPlayerArrayForScout:(Scout*) scout Type:(NSString*) type
{
    //TODO: Make scout tasks
    return nil;
}
@end

@implementation Scout
@synthesize SCOUTID;
@synthesize NAME;
@synthesize JUDGEMENT; // judging ability + potential
@synthesize YOUTH; // judging potential in < 23yr olds
@synthesize VALUE; // abilty to price ratio
@synthesize KNOWLEDGE; // useful perks spotting
@synthesize DILIGENCE; // probabilty of more names


- (id) initWithScoutID: (NSInteger) thisScoutID {
    self = [super init];
    if (self) {
        NSDictionary* result = [[DatabaseModel myDB]getResultDictionaryForTable:@"scouts" withKeyField:@"SCOUTID" withKey:thisScoutID];
        [result enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self setValuesForKeysWithDictionary:result];
            
        }];
    
    }
    return self;

}
@end
