//
//  DXPCode.h
//  CommentStatement
//
//  Created by 超盟 on 2019/1/28.
//  Copyright © 2019年 wintel. All rights reserved.
//
#import <XcodeKit/XcodeKit.h>
#import <Foundation/Foundation.h>

@interface DXPCode : NSObject

/** 复制当前行 */
+ (void)dxpCode_CopyLine:(XCSourceEditorCommandInvocation *)invocation;

/** 导入选中类 */
+ (void)dxpCode_ImportClass:(XCSourceEditorCommandInvocation *)invocation;

/** 自动生成Get Set  同时生成编译报错所有分开 */
+ (void)dxpCode_AutomaticSET:(XCSourceEditorCommandInvocation *)invocation;
+ (void)dxpCode_AutomaticGET:(XCSourceEditorCommandInvocation *)invocation;

/** 注释当前行 */
+ (void)dxpCode_AnnotationLine:(XCSourceEditorCommandInvocation *)invocation;

/** 一键替换 */
+ (void)dxpCode_AKeyReplace:(XCSourceEditorCommandInvocation *)invocation;

/** 删掉注释 */
+ (void)dxpCode_DeleteComment:(XCSourceEditorCommandInvocation *)invocation;

@end
