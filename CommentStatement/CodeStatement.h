//
//  CodeStatement.h
//  WTToolBox
//
//  Created by wq on 18/8/30.
//  Copyright © 2018年 wintelsui. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface CodeStatement : NSObject
+ (void)statementCommand:(XCSourceEditorCommandInvocation *)invocation;
+ (void)documentAdd:(XCSourceEditorCommandInvocation *)invocation;
@end
