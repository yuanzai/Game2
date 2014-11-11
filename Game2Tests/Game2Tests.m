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
#import "GameModel.h"
#import "Scouting.h"
#import "Team.h"
#import "LineUp.h"

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
    NSLog(@"%@",[[[DatabaseModel alloc]init]databasePath]);
}



- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
