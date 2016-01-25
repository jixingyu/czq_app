//
//  NSDictionaryAdditions.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "NSDictionaryAdditions.h"


@implementation NSDictionary (Additions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    return [self objectForKey:key] == [NSNull null] ? defaultValue 
						: [[self objectForKey:key] boolValue];
}

- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
	return [self objectForKey:key] == [NSNull null] 
				? defaultValue : [[self objectForKey:key] intValue];
}

- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
	NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }
	struct tm created;
    time_t now;
    time(&now);
    
	if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		return mktime(&created);
	}
	return defaultValue;
}

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
	return [self objectForKey:key] == [NSNull null] 
		? defaultValue : [[self objectForKey:key] longLongValue];
}

- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
	return [self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null] || [self objectForKey:key] == [NSString stringWithFormat: @"%@", @"(null)"]
				? nil : [self objectForKey:key];
}

- (NSDate *)getDateValueForKey:(NSString *)key defaultValue:(NSDate *)defaultValue{
	//2011-03-08T21:56:19+08:
	/*
	 2011-03-10 15:50:51.077 MaMaShai[9377:207] 2011-03-08T21:56:19+08:00
	 2011-03-10 15:50:51.078 MaMaShai[9377:207] 2011-03-08T21:56:19+08:00
	 2011-03-10 15:50:51.083 MaMaShai[9377:207] 2010-02-09T20:23:35+08:00
	 */
	
	NSString *stringTime   = [self objectForKey:key];
	if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }

	stringTime = [stringTime stringByReplacingOccurrencesOfString:@"+00:00" withString:@""];
	stringTime = [stringTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:@"GMT"];
	[formatter setTimeZone:tzGMT];
	[formatter setDateFormat:(@"yyyy-MM-dd HH:mm:ss")];
	NSDate* date = [formatter dateFromString:stringTime];
	
    //[stringTime release];
	return date;
}

@end
