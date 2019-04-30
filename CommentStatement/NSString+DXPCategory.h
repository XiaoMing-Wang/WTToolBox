//
//  NSString+DXPCategory.h
//  类库
//
//  Created by wq on 16/8/28.
//  Copyright © 2016年 WQ. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSString (DXPCategory)
@property (nonatomic, assign, readonly) BOOL available;

/** 是否有字符*/
- (BOOL)haveCharacter;
- (BOOL)isNumber;
- (BOOL)isChinese;
- (BOOL)isLetters;
- (BOOL)isAllCharacterString;

/** 是去掉空格*/
- (NSString *)removeSpaces;

/** 获取类名 */
- (NSString *)getClassName;
- (NSString *)getInterfaceName;


/** 获取属性名 */
- (NSString *)getAttribute;
@end

NS_ASSUME_NONNULL_END
