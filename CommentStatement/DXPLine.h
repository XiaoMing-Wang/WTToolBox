//
//  DXPLine.h
//  CommentStatement
//
//  Created by 超盟 on 2019/1/29.
//  Copyright © 2019年 wintel. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>
#import <Foundation/Foundation.h>
@class LineObj;

@interface DXPLine : NSObject

/** 类名 */
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *classType;

/** 需要替换的字典 */
@property (nonatomic, copy) NSString *replaceString ;

/** all */
@property (nonatomic, strong) NSMutableArray<NSString *> *allArray;

/** define */
@property (nonatomic, assign) LineObj *defines;
@property (nonatomic, strong) NSMutableArray<LineObj *> *definesArray;

/** import */
@property (nonatomic, assign) LineObj *imports;
@property (nonatomic, strong) NSMutableArray<LineObj *> *importsArray;

/** property数组 */
@property (nonatomic, assign) LineObj *property;
@property (nonatomic, strong) NSMutableArray<LineObj *> *propertyArray;

/** get set 已经实现的数组 */
@property (nonatomic, strong) NSMutableArray<LineObj *> *setArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *getArray;

/** interface */
@property (nonatomic, strong) LineObj *interface;

/** implementation */
@property (nonatomic, strong) LineObj *implementation;

/** 当前需要判断end的 */
@property (nonatomic, strong) LineObj *currentJudge;

/** 初始化 */
- (instancetype)initWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end

@interface LineObj : NSObject
@property (nonatomic, assign) NSInteger startLine;
@property (nonatomic, assign) NSInteger endLine;

@property (nonatomic, strong) NSString *lingString;
@property (nonatomic, assign) NSInteger currentLine;
+ (instancetype)lineObj:(NSString *)lingString currentLine:(NSInteger)currentLine;
@end
