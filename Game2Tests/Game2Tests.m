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
#import "C2DArray_double.h"
#import "GlobalVariableModel.h"

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
    NSLog(@"%@",[[GameModel myDB]databasePath]);
}

- (void) testC2dArray
{
//    C2DArray_double* n = [[C2DArray_double alloc]initWithRows:2 Columns:2];
//    [n setValue:1.1 atRow:1 Column:1];
//    NSLog(@"%f",[n valueAtRow:1 Column:1]);
    
    
    /*
    GlobalVariableModel* globals = [GlobalVariableModel myGlobalVariable];
    NSDictionary* result = [globals trainingProfile];
    C2DArray_double* c =[result objectForKey:@"DECAY"];
    double d = [c valueAtRow:1 Column:1];
    NSLog(@"%f",d);*/
}

- (void)testExample
{
    
    int* temp;
    
    NSLog(@"%d",temp[0]);
    
    if (temp[0] == nil)
        NSLog(@"not exists");
    if (temp != nil)
        NSLog(@"fail");

    
    temp = malloc(sizeof(int)*5);
    temp[0] =1;
    if (temp != nil)
        NSLog(@"exists");
    if (temp == nil)
        NSLog(@"fail");

    
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
