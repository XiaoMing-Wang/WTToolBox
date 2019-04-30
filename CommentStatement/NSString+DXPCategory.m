//
//  NSString+DXPCategory.m
//  类库
//
//  Created by wq on 16/8/28.
//  Copyright © 2016年 WQ. All rights reserved.
//

#import "NSString+DXPCategory.h"
#include <CommonCrypto/CommonCrypto.h>
#import <CoreText/CoreText.h>
#include <zlib.h>
#import <objc/runtime.h>

@implementation NSString (DXPCategory)

+ (void)load {
    Method method1 = class_getInstanceMethod(self, @selector(stringByAppendingString:));
    Method method2 = class_getInstanceMethod(self, @selector(safeStringByAppendingString:));
    method_exchangeImplementations(method1, method2);
}

/** 防空判断 */
- (NSString *)safeStringByAppendingString:(NSString *)aString {
    if (!aString) {
        NSLog(@"stringByAppendingString: ____________________字符串为空");
        NSLog(@"stringByAppendingString: ____________________字符串为空");
        NSLog(@"stringByAppendingString: ____________________字符串为空");
        return self;
    }
    return [self safeStringByAppendingString:aString];
}
/** 判断是否可用 */
- (BOOL)available {
    return (self && [self isKindOfClass:[NSString class]] && self.length != 0);
}
/** 是去掉空格*/
- (NSString *)removeSpaces {
    if (self.available == NO) return nil;
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark ________________________________________________________ 正则校验

/** 是否有字符*/
- (BOOL)haveCharacter {
    if (self.length == 0) return NO;
    NSString *phoneRegex = @",+*;#";
    NSRange urgentRange = [self rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:phoneRegex]];
    if (urgentRange.location == NSNotFound) return NO;
    return YES;
}
/** 验证是否是数字*/
- (BOOL)isNumber {
    if (self.length == 0) return NO;
    NSString *isNumber = @"^[0-9]*$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isNumber];
    return [phoneTest evaluateWithObject:self];
}
/** 中文 */
- (BOOL)isChinese {
    if (self.length == 0) return NO;
    NSString *phoneRegex = @"[\u4e00-\u9fa5]";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}
/** 英文字母 */
- (BOOL)isLetters {
    if (self.length == 0) return NO;
    NSString *phoneRegex = @"^[a-zA-Z][a-zA-Z0-9_]{3,15}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}
/** 判断是否为纯符号 */
- (BOOL)isAllCharacterString {
    BOOL isAllCharacter = YES;
    for (int i = 0; i < self.length; i++) {
        NSString *subStr = [self substringWithRange:NSMakeRange(i, 1)];
        if (subStr.isNumber || subStr.isChinese || self.isLetters) {
            isAllCharacter = NO;break;
        }
    }
    return isAllCharacter;
}
/** 获取类名 @property(nonatomic,copy)NSString*titles;\n @property NSString *titles;\n*/
- (NSString *)getClassName {
    __block NSString * className = self.copy;
    
    className = [className stringByReplacingOccurrencesOfString:@"@property" withString:@""];
    className = [className componentsSeparatedByString:@";"].firstObject;
    if ([className containsString:@")"] ) {
        className = [className componentsSeparatedByString:@")"].lastObject;
    }
    
    if ([className containsString:@"*"] ) {
        NSArray * array = [className componentsSeparatedByString:@"*"];
        className = [array.firstObject removeSpaces];
        className = [className stringByAppendingString:@" *"];
        return className;
    } else {
        NSArray * array = [className componentsSeparatedByString:@" "];
        [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.removeSpaces.length > 0) {
                className = obj.removeSpaces;
                *stop = YES;
            }
        }];
        return className;
    }
    return nil;
}

- (NSString *)getInterfaceName {
    NSString * className = self.copy;
    className = [className stringByReplacingOccurrencesOfString:@"@interface" withString:@""];
    
    if ([className containsString:@"("] ) {
        className = [className componentsSeparatedByString:@"("].firstObject;
        className = className.removeSpaces;
    }
    
    if ([className containsString:@":"] ) {
        className = [className componentsSeparatedByString:@":"].firstObject;
        className = className.removeSpaces;
    }
    return className;
}



- (NSString *)getAttribute {
    __block NSString * attribute = self.copy;
    
    attribute = [attribute stringByReplacingOccurrencesOfString:@"@property" withString:@""];
    attribute = [attribute componentsSeparatedByString:@";"].firstObject;
    if ([attribute containsString:@")"] ) {
        attribute = [attribute componentsSeparatedByString:@")"].lastObject;
    }
    
    if ([attribute containsString:@"*"] ) {
        NSArray * array = [attribute componentsSeparatedByString:@"*"];
        return [array.lastObject removeSpaces];
    } else {
        NSArray * array = [attribute componentsSeparatedByString:@" "];
        [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.removeSpaces.length > 0) attribute = obj.removeSpaces;
        }];
        return attribute;
    }
    return nil;
}

@end

