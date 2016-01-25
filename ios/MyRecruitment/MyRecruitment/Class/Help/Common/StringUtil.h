//
//  StringUtil.h
//  TwitterFon
//
//  Created by kaz on 7/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>

@interface NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent;
+(NSString *)encodeString:(NSString *)string;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;
+(NSString *)queryStringWithBaseString:(NSString *)fullPath parameters:(NSDictionary *)params prefixed:(BOOL)prefixed;
+ (NSString *)getURL:(NSString *)path requestdomain:(NSString *)requestdomain queryParameters:(NSMutableDictionary*)params secureConnection:(BOOL*) secureConnection;

//isFullString 为 NO的话，如果时间就是当前年度的话，只返回月：日：时间 不返回年份
+(NSString*) initFromDate:(NSDate *)date isFullString:(BOOL)isFullString;

+(NSString *)MD5UpperCase:(NSString *)string;
+(NSString *)MD5LowerCase:(NSString *)string;
+ (NSString*)stringWithNewUUID;
@end


