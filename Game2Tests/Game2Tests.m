//
//  Game2Tests.m
//  Game2Tests
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Generator.h"
#import "DatabaseModel.h"
@interface Game2Tests : XCTestCase

@end

@implementation Game2Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDatabase
{
    NSArray* players = [[[DatabaseModel alloc]init]getArrayFrom:@"players" withSelectField:@"DISPLAYNAME" whereKeyField:@"PLAYERID" hasKey:@2];
    XCTAssertTrue([players count] == 1,@"get 1 player in players table");

}

- (void)testGenerate
{
    Generator* newGenerator = [[Generator alloc]init];
    [newGenerator generatePlayersWithSeason:1];
}

- (void)testARC4random
{
    for (int i = 0; i < 100; i++){
        NSInteger k = arc4random() % 10000;
    }
}
- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
