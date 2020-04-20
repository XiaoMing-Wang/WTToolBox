//
//  SourceEditorExtension.h
//  CommentStatement
//
//  Created by wintelsui on 18/8/30.
//  Copyright © 2018年 wq. All rights reserved.
//

#import "CommentStatementCommand.h"
#import "DXPCode.h"
#import "CodeStatement.h"

@implementation CommentStatementCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation
                   completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
    
    NSString *identifier = invocation.commandIdentifier;
    
    /** 复制单行 */
    if ([identifier hasSuffix:@"CopyLine"]) [DXPCode dxpCode_CopyLine:invocation];
    
    /** 导入类 */
    if ([identifier hasSuffix:@"ImportClass"]) [DXPCode dxpCode_ImportClass:invocation];
    if ([identifier hasSuffix:@"SortingClass"]) [DXPCode dxpCode_SortingClass:invocation];
    
    /** 自动生成GET */
    if ([identifier hasSuffix:@"AutomaticGET"]) [DXPCode dxpCode_AutomaticGET:invocation];
    
    /** 自动生成SET */
    if ([identifier hasSuffix:@"AutomaticSET"]) [DXPCode dxpCode_AutomaticSET:invocation];
    
    /** 注释当前行 */
    if ([identifier hasSuffix:@"AutomaticAnnotationLine"]) [DXPCode dxpCode_AnnotationLine:invocation];
    
    /** 一键替换 */
    if ([identifier hasSuffix:@"AKeyReplace"]) [DXPCode dxpCode_AKeyReplace:invocation];
    
    /** 删掉注释 */
    if ([identifier hasSuffix:@"DeleteComment"]) [DXPCode dxpCode_DeleteComment:invocation];
    
    completionHandler(nil);
}

@end
