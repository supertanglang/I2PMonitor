//
//  RCPreferences.m
//  I2PRemoteControl
//
//  Created by miximka on 13/05/14.
//  Copyright (c) 2014 miximka. All rights reserved.
//

#import "RCPreferences.h"
#import "RCLoginItemManager.h"

//=========================================================================
@implementation RCPreferences
//=========================================================================

static RCPreferences* _sharedPrefs;
+ (RCPreferences *)sharedPreferences
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      _sharedPrefs = [[[self class] alloc] init];
                  });
    
	return _sharedPrefs;
}

//=========================================================================

+ (void)initialize
{
	//Register defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"127.0.0.1", PREFS_KEY_ROUTER_HOST,
                                 [NSNumber numberWithUnsignedInteger:7650], PREFS_KEY_ROUTER_PORT,
                                 [NSNumber numberWithBool:YES], PREFS_KEY_FIRST_START,
                                 [NSNumber numberWithBool:NO], PREFS_KEY_START_ON_SYSTEM_STARTUP,
								 nil];
	
    [defaults registerDefaults:appDefaults];
}

//=========================================================================

- (NSString *)routerHost
{
    return [self objectForKey:PREFS_KEY_ROUTER_HOST];
}

//=========================================================================

- (void)setRouterHost:(NSString *)host
{
    [self setObject:host forKey:PREFS_KEY_ROUTER_HOST];
}

//=========================================================================

- (NSUInteger)routerPort
{
    return [[self objectForKey:PREFS_KEY_ROUTER_PORT] unsignedIntegerValue];
}

//=========================================================================

- (void)setRouterPort:(NSUInteger)port
{
    [self setObject:[NSNumber numberWithUnsignedInteger:port] forKey:PREFS_KEY_ROUTER_PORT];
}

//=========================================================================

- (BOOL)isFirstStart
{
    return [self boolForKey:PREFS_KEY_FIRST_START];
}

//=========================================================================

- (void)setIsFirstStart:(BOOL)flag
{
    [self setBool:flag forKey:PREFS_KEY_FIRST_START];
}

//=========================================================================

- (BOOL)startOnSystemStartup
{
	return [self boolForKey:PREFS_KEY_START_ON_SYSTEM_STARTUP];
}

//=========================================================================

- (void)setStartOnSystemStartup:(BOOL)flag
{
	[self setBool:flag forKey:PREFS_KEY_START_ON_SYSTEM_STARTUP];
	
	//Add or remove item immediately
	[self syncLoginItemPrefs];
}

//=========================================================================

- (void)syncLoginItemPrefs
{
	RCLoginItemManager *mgr = [RCLoginItemManager new];
	
	BOOL isInLoginItemList = [mgr isInLoginItemList];
	
	//At first, validate login item if it exists
	if (isInLoginItemList && ![mgr isLoginItemValid])
	{
		//Invalid login item detected, remove it completely
		DDLogWarn(@"Will repair invalid login item...");

		[mgr removeLoginItem];
		isInLoginItemList = NO;
	}
	
	//Now remove or add login item, in dependency of current settings
	if ([self startOnSystemStartup] && !isInLoginItemList)
	{
		//Need to add login item
		[mgr addOrUpdateLoginItem:NO];
	}
	else if (![self startOnSystemStartup] && isInLoginItemList)
	{
		//Remove from item list
		[mgr removeLoginItem];
	}
}

//=========================================================================
@end
//=========================================================================