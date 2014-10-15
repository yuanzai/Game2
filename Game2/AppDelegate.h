//
//  AppDelegate.h
//  Game2
//
//  Created by Junyuan Lau on 15/10/14.
//  Copyright (c) 2014 jauunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property NSString* databaseName;
@property NSString* databasePath;
- (void) getDBPath;
- (void) createAndCheckDatabase;

@end
