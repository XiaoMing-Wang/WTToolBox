//
//  DXPCode.m
//  CommentStatement
//
//  Created by 超盟 on 2019/1/28.
//  Copyright © 2019年 wintel. All rights reserved.
//

#import "DXPCode.h"
#import "Macros.h"
#import "NSString+DXPCategory.h"
#import "DXPLine.h"

@implementation DXPCode

/** 复制当前行 */
+ (void)dxpCode_CopyLine:(XCSourceEditorCommandInvocation *)invocation {
    NSMutableArray * insertArray = @[].mutableCopy;
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
    
    /** 开始行数 */
    NSInteger startLine = selectionRange.start.line;
    
    /** 结束行数 */
    NSInteger endLine = selectionRange.end.line;
    NSInteger endColumn = selectionRange.end.column;
    
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *text = invocation.buffer.lines[i];
        [insertArray addObject:text];
        if (endColumn < text.length) endColumn = selectionRange.end.column + text.length;
    }
    
    /** 复制 */
    NSInteger addStartLine = endLine + 1;
    [insertArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [invocation.buffer.lines insertObject:obj atIndex:addStartLine + idx];
    }];
    
    XCSourceTextRange *replaceRange = [[XCSourceTextRange alloc] init];
    replaceRange.start = (XCSourceTextPosition){ addStartLine + insertArray.count - 1, endColumn};
    replaceRange.end = (XCSourceTextPosition){ addStartLine + insertArray.count - 1, endColumn};
    [invocation.buffer.selections removeAllObjects];
    [invocation.buffer.selections addObject:replaceRange];
}

/** 导入选中类 */
+ (void)dxpCode_ImportClass:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
    
    /** 开始行数 */
    NSInteger startLine = selectionRange.start.line;
    NSString *text = invocation.buffer.lines[startLine];
    
    NSInteger startColumn = selectionRange.start.column;
    NSInteger endColumn = selectionRange.end.column;
    text = [text substringWithRange:NSMakeRange(startColumn, endColumn - startColumn)];
    if (text.isLetters == NO) return;
    NSString *importString = [NSString stringWithFormat:@"#import \"%@.h\"\n",text];
    
    //所有的代码
    NSArray <NSString *>*stringArray = [NSArray arrayWithArray:invocation.buffer.lines];
    __block NSInteger insertRow = 0;
    __block NSInteger interface = 0;
    __block NSInteger implementation = 0;
    
    NSMutableArray *importArray = @[].mutableCopy;
    [stringArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        /** 已经存在 */
        if ([obj isEqualToString:importString]) {
            insertRow = -1;
            *stop = YES;
        }
        
        /** import数组 */
        if ([obj hasPrefix:@"#import"]) [importArray addObject:obj];
        if ([obj hasPrefix:@"@interface"]) interface = idx;
        if ([obj hasPrefix:@"@implementation"]) implementation = idx;
    }];
    
    /** 已经存在 */
    if (insertRow == -1) return;
    
    
    /** 不存在插入 */
    if (importArray.count > 0) {
        NSString * lastString = importArray.lastObject;
        insertRow = [stringArray indexOfObject:lastString];
    } else {
        if (interface > 0) insertRow = interface - 1;
        else if (implementation > 0) insertRow = implementation - 1;
    }
    [invocation.buffer.lines insertObject:importString atIndex:insertRow];
}

+ (void)dxpCode_SortingClass:(XCSourceEditorCommandInvocation *)invocation {
    DXPLine * dxpLine = [[DXPLine alloc] initWithInvocation:invocation];
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
    
    /** 开始行数 */
    NSMutableArray *importArray = @[].mutableCopy;
    NSInteger startLine = selectionRange.start.line;
    NSInteger endLine = selectionRange.end.line;
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *text = invocation.buffer.lines[i];
        if ([text.removeSpaces hasPrefix:@"#import"]) [importArray addObject:text];
    }
    
    for (NSString *text in importArray) {
        NSInteger index = [invocation.buffer.lines indexOfObject:text];
        [invocation.buffer.lines removeObjectAtIndex:index];
    }
    
    for (int i = 0; i < importArray.count; i++) {
        for (int j = i + 1; j < importArray.count; j++) {
            NSString *text1 = importArray[i];
            NSString *text2 = importArray[j];
            if (text1.length > text2.length) {
                [importArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    for (int i = 0; i < importArray.count; i++) {
        NSInteger insertRow = i + startLine;
        NSString *text = importArray[i];
        [invocation.buffer.lines insertObject:text atIndex:insertRow];
    }
}

/** 自动生成 Set */
+ (void)dxpCode_AutomaticSET:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
    DXPLine * dxpLine = [[DXPLine alloc] initWithInvocation:invocation];
    
    NSInteger startLine = selectionRange.start.line;
    NSInteger endLine = selectionRange.end.line;
    
    //@property 需要添加的数组
    NSMutableArray <NSString *>*propertyArray = @[].mutableCopy;
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *text = invocation.buffer.lines[i];
        if ([text hasPrefix:@"@property"]) [propertyArray addObject:text];
    }
    if (propertyArray.count == 0) return;

    /** 已经存在的数组 */
    NSMutableArray *settingArray = @[].mutableCopy;
    [dxpLine.setArray enumerateObjectsUsingBlock:^(LineObj *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [settingArray addObject:obj.lingString];
    }];

    //@property拼接
    NSString * setStart = @"- (void)set";
    __block NSMutableString * methods = [NSMutableString string];
    [propertyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * className = obj.getClassName;
        NSString * attribute = obj.getAttribute;
        NSString * pro = attribute.copy;
        
        if(pro && pro.length > 0) {
            NSString * firstLetter = [[pro substringToIndex:1] capitalizedString];
            NSRange range = NSMakeRange(0, 1);
            pro = [pro stringByReplacingCharactersInRange:range withString:firstLetter];
        }

        if ([settingArray containsObject:attribute]) return;
        [methods appendString:[NSString stringWithFormat:@"%@%@:(%@)%@ {\n    _%@ = %@;\n}\n",setStart,pro,className,attribute,attribute,attribute]];
    }];
    
    if (!methods.available) return;
    if (dxpLine.implementation.endLine > 0) {
        [invocation.buffer.lines insertObject:methods atIndex:dxpLine.implementation.endLine];
    } else {
        [invocation.buffer.lines insertObject:methods atIndex:dxpLine.interface.endLine];
    }
    [self moveLine:invocation line:dxpLine.implementation.endLine];
}

/** 自动生成 Get */
+ (void)dxpCode_AutomaticGET:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
    DXPLine * dxpLine = [[DXPLine alloc] initWithInvocation:invocation];
    NSInteger startLine = selectionRange.start.line;
    NSInteger endLine = selectionRange.end.line;
    
    //@property 需要添加的数组
    NSMutableArray <NSString *>*propertyArray = @[].mutableCopy;
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *text = invocation.buffer.lines[i];
        if ([text hasPrefix:@"@property"]) [propertyArray addObject:text];
    }
    if (propertyArray.count == 0) return;
    
    //已经存在的数组
    NSMutableArray *gettingArray = @[].mutableCopy;
    [dxpLine.getArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [gettingArray addObject:obj];
    }];
    
    //@property拼接
    __block NSMutableString * methods = [NSMutableString string];
    [propertyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * className = obj.getClassName;
        NSString * classNameSpace = [className stringByReplacingOccurrencesOfString:@" *" withString:@""];
        NSString * attribute = obj.getAttribute;
        if ([gettingArray containsObject:attribute]) return;
        
        if ([classNameSpace.removeSpaces isEqualToString:@"NSInteger"] ||
            [classNameSpace.removeSpaces isEqualToString:@"int"] ||
            [classNameSpace.removeSpaces isEqualToString:@"BOOL"] ||
            [classNameSpace.removeSpaces isEqualToString:@"NSUInteger"] ||
            [classNameSpace.removeSpaces isEqualToString:@"char"] ||
//            [classNameSpace.removeSpaces isEqualToString:@"int"] ||
            [classNameSpace.removeSpaces isEqualToString:@"CGFloat"]) {
            
            [methods appendString:
             [NSString stringWithFormat:@"- (%@)%@ {\n    return _%@;\n}\n",className,attribute,attribute]];
            
        } else if ([classNameSpace.removeSpaces isEqualToString:@"NSString"] ||
                   [classNameSpace.removeSpaces isEqualToString:@"NSString"]) {
            
            [methods appendString:
             [NSString stringWithFormat:@"- (%@)%@ {\n    if (!_%@) _%@ = @"";\n    return _%@;\n}\n",className,attribute,attribute,attribute,attribute]];
            
        } else if ([classNameSpace.removeSpaces isEqualToString:@"NSMutableArray"] ||
                   [classNameSpace.removeSpaces isEqualToString:@"NSArray"]) {
            
            [methods appendString:[NSString stringWithFormat:@"- (%@)%@ {\n    if (!_%@) _%@ = @[].mutableCopy;\n    return _%@;\n}\n",className,attribute,attribute,attribute,attribute]];
            
        } else if ([classNameSpace.removeSpaces isEqualToString:@"NSMutableDictionary"] ||
                   [classNameSpace.removeSpaces isEqualToString:@"NSDictionary"]) {
            
            [methods appendString:[NSString stringWithFormat:@"- (%@)%@ {\n    if (!_%@) _%@ = @{}.mutableCopy;\n    return _%@;\n}\n",className,attribute,attribute,attribute,attribute]];
            
        } else {
            [methods appendString:[NSString stringWithFormat:@"- (%@)%@ {\n    if (!_%@) _%@ = [[%@ alloc] init];\n    return _%@;\n}\n",className,attribute,attribute,attribute,classNameSpace,attribute]];
        }
    }];

    if (!methods.available) return;
    if (dxpLine.implementation.endLine > 0) {
        [invocation.buffer.lines insertObject:methods atIndex:dxpLine.implementation.endLine];
    } else {
        [invocation.buffer.lines insertObject:methods atIndex:dxpLine.interface.endLine];
    }
    [self moveLine:invocation line:dxpLine.implementation.endLine];
}

/** 注释当前行 */
+ (void)dxpCode_AnnotationLine:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
   
    /** 开始行数 */
    NSInteger startLine = selectionRange.start.line;
    NSInteger endLine = selectionRange.end.line;
    
    /** 结束行数 */
    NSInteger startColumn = selectionRange.start.column;
    NSInteger endColumn = selectionRange.end.column;
    NSString *text = [invocation.buffer.lines[startLine] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    //未选中
    if (startLine == endLine && startColumn == endColumn) {
        if ([text containsString:@"/**"] && [text containsString:@"*/"]) {
            NSString *textNew = [text stringByReplacingOccurrencesOfString:@"/**" withString:@""];
            textNew = [textNew stringByReplacingOccurrencesOfString:@"*/" withString:@""];
            [invocation.buffer.lines removeObjectAtIndex:startLine];
            [invocation.buffer.lines insertObject:textNew atIndex:startLine];
        } else {
            BOOL haveSpace = [text hasPrefix:@"    "];
            if (haveSpace) text = [text stringByReplacingOccurrencesOfString:@"    " withString:@""];
            NSString *textNew = [NSString stringWithFormat:@"/** %@ */",text];
            if (haveSpace) textNew = [NSString stringWithFormat:@"    /** %@ */",text];
            [invocation.buffer.lines removeObjectAtIndex:startLine];
            [invocation.buffer.lines insertObject:textNew atIndex:startLine];
            if ([textNew isEqualToString:@"/**  */"]) {
                XCSourceTextRange *replaceRange = [[XCSourceTextRange alloc] init];
                replaceRange.start = (XCSourceTextPosition){ startLine, 4};
                replaceRange.end = (XCSourceTextPosition){ startLine, 4};
                [invocation.buffer.selections removeAllObjects];
                [invocation.buffer.selections addObject:replaceRange];
            }
        }
        
        //选中
    } else {
        if (startLine == endLine) { // 一行
            NSInteger count = endColumn - startColumn;
            NSString * selectedString = [text substringWithRange:NSMakeRange(startColumn, count)];
            selectedString = [selectedString stringByReplacingOccurrencesOfString:@"//" withString:@""];
            NSString * selectedStringNew = [NSString stringWithFormat:@"/** %@ */",selectedString];
            NSString * oldHeaderString = [text substringToIndex:startColumn];
            NSString * oldFootString = [text substringFromIndex:startColumn + count];
            NSString * textNew = [[oldHeaderString stringByAppendingString:selectedStringNew] stringByAppendingString:oldFootString];
            [invocation.buffer.lines removeObjectAtIndex:startLine];
            [invocation.buffer.lines insertObject:textNew atIndex:startLine];
        } else { // 多行
            
            //开始
            NSString * selectedString = [text substringFromIndex:startColumn];
            NSString * selectedStringNew = [NSString stringWithFormat:@" /** %@",selectedString];
            NSString * oldHeaderString = [text substringToIndex:startColumn];
            NSString * textNew = [oldHeaderString stringByAppendingString:selectedStringNew];
            [invocation.buffer.lines removeObjectAtIndex:startLine];
            [invocation.buffer.lines insertObject:textNew atIndex:startLine];
            
            //结束
            NSString *endText = [invocation.buffer.lines[endLine] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSString *endSelectedString = [endText substringToIndex:endColumn];
            NSString *endSelectedStringNew = [NSString stringWithFormat:@"%@ */",endSelectedString];
            [invocation.buffer.lines removeObjectAtIndex:endLine];
            [invocation.buffer.lines insertObject:endSelectedStringNew atIndex:endLine];
        }
    }
}

/** 一键替换 */
+ (void)dxpCode_AKeyReplace:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
       
    /** 开始行数 */
    NSInteger startLine = selectionRange.start.line;
    NSInteger endLine = selectionRange.end.line;
    
    /** <#object#> ==> <#object#> */
    NSString *replaceString = invocation.buffer.lines[startLine].mutableCopy;
    if ([replaceString containsString:@"==>"] == NO) return;
    replaceString = [replaceString stringByReplacingOccurrencesOfString:@"/" withString:@""];
    replaceString = [replaceString stringByReplacingOccurrencesOfString:@"*" withString:@""];
    replaceString = [replaceString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *fromString = [replaceString componentsSeparatedByString:@"==>"].firstObject;
    NSString *toString = [replaceString componentsSeparatedByString:@"==>"].lastObject;
    if ([fromString isEqualToString:toString]) return;
    if ([toString isEqualToString:@"<#object#>"]) return;
    
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *lineString = invocation.buffer.lines[i].mutableCopy;
        if ([lineString containsString:fromString] && ![lineString containsString:@"==>"])  {
            lineString = [lineString stringByReplacingOccurrencesOfString:fromString withString:toString];
            lineString = [lineString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [invocation.buffer.lines replaceObjectAtIndex:i withObject:lineString];
        }
        
        if ([toString hasPrefix:@"self."]) {
            NSRange range = [lineString rangeOfString:@"self."];
            lineString = [lineString substringFromIndex:range.location];
            lineString = [@"    " stringByAppendingString:lineString];
            [invocation.buffer.lines replaceObjectAtIndex:i withObject:lineString];
        }
                
    }
}

/** 删掉注释 */
+ (void)dxpCode_DeleteComment:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (![self isSelections:invocation]) return;
    
    /** 开始行数 */
    NSInteger startLine = selectionRange.start.line;
    NSInteger endLine = selectionRange.end.line;
    
    /** 结束行数 */
    NSInteger startColumn = selectionRange.start.column; /**  */
    NSInteger endColumn = selectionRange.end.column;
    if (startLine == endLine && startColumn == endColumn) return;
    BOOL needRemove = NO;
    if (endLine >= invocation.buffer.lines.count) endLine = invocation.buffer.lines.count - 1;
    for (NSInteger i = endLine; i >= startLine; i--) {
       
        NSString *lineString = invocation.buffer.lines[i].mutableCopy;
        
        lineString = lineString.removeSpaces;
        lineString = [lineString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([lineString hasPrefix:@"//"]) {
            [invocation.buffer.lines removeObjectAtIndex:i];
            
        } else if (([lineString containsString:@"/*"] || [lineString containsString:@"/**"]) && [lineString containsString:@"*/"]) {
            lineString = invocation.buffer.lines[i].mutableCopy;
            NSRange startRange = [lineString rangeOfString:@"/**"];
            NSRange endRange = [lineString rangeOfString:@"*/"];
            NSRange range = NSMakeRange(startRange.location, endRange.location + endRange.length - startRange.location);
            //NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            NSString *result = [lineString substringWithRange:range];
            
            lineString = [lineString stringByReplacingOccurrencesOfString:result withString:@""];
            [invocation.buffer.lines removeObjectAtIndex:i];
            [invocation.buffer.lines insertObject:lineString atIndex:i];

        } else if (!([lineString containsString:@"/*"] || [lineString containsString:@"/**"]) && [lineString containsString:@"*/"]) {
            needRemove = YES;
            [invocation.buffer.lines removeObjectAtIndex:i];
            
        } else if (([lineString containsString:@"/*"] || [lineString containsString:@"/**"]) && ![lineString containsString:@"*/"]) {
            needRemove = NO;
            [invocation.buffer.lines removeObjectAtIndex:i];
            
        } else if ([lineString containsString:@"//"]) {
            lineString = invocation.buffer.lines[i].mutableCopy;
            NSRange range = [lineString rangeOfString:@"//"];
            NSString *result = [lineString substringToIndex:range.location - 1];
            [invocation.buffer.lines removeObjectAtIndex:i];
            [invocation.buffer.lines insertObject:result atIndex:i];
            
        } else if (needRemove) {
            
            [invocation.buffer.lines removeObjectAtIndex:i];
        }
    }
}

/** 跳转到选择行 */
+ (void)moveLine:(XCSourceEditorCommandInvocation *)invocation line:(NSInteger)line {
    XCSourceTextRange *replaceRange = [[XCSourceTextRange alloc] init];
    replaceRange.start = (XCSourceTextPosition){ line, 0};
    replaceRange.end = (XCSourceTextPosition){ line, 0};
    [invocation.buffer.selections removeAllObjects];
    [invocation.buffer.selections addObject:replaceRange];
}

/** 是否选中 */
+ (BOOL)isSelections:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *selectionRange = invocation.buffer.selections.firstObject;
    if (selectionRange) return YES;
    return NO;
}

@end
