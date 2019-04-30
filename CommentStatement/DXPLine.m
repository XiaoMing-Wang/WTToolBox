//
//  DXPLine.m
//  CommentStatement
//
//  Created by 超盟 on 2019/1/29.
//  Copyright © 2019年 wintel. All rights reserved.
//

#import "DXPLine.h"
#import "NSString+DXPCategory.h"
#import "Macros.h"

@interface DXPLine ()
@property (nonatomic, strong) XCSourceEditorCommandInvocation *invocation;
@end
@implementation DXPLine

/** 初始化 */
- (instancetype)initWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    self = [super init];
    self.definesArray = @[].mutableCopy;
    self.importsArray = @[].mutableCopy;
    self.propertyArray = @[].mutableCopy;
    self.setArray = @[].mutableCopy;
    self.getArray = @[].mutableCopy;
    self.interface = [LineObj new];
    self.implementation = [LineObj new];
    
    self.invocation = invocation;
    
    self.allArray = [NSArray arrayWithArray:invocation.buffer.lines].mutableCopy;
    [self.allArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        /** className */
        if ((![obj isEqualToString:@"//\n"]) && [obj containsString:@"."] && self.className == nil) {
            NSString * className = [obj stringByReplacingOccurrencesOfString:@"//" withString:@""].removeSpaces;
            self.className = [className componentsSeparatedByString:@"."].firstObject;
            self.classType = [className componentsSeparatedByString:@"."].lastObject;
        }
        
        /** define */
        [self judgeLocationArray:self.definesArray idx:idx bufferString:obj judgeString:@"#define"];
        [self judgeLocationArray:self.definesArray Line:self.defines];
        
        /** #import */
        [self judgeLocationArray:self.importsArray idx:idx bufferString:obj judgeString:@"#import"];
        [self judgeLocationArray:self.importsArray Line:self.imports];
        
        /** @property */
        [self judgeLocationArray:self.propertyArray idx:idx bufferString:obj judgeString:@"@property"];
        [self judgeLocationArray:self.propertyArray Line:self.property];
        
        
        /** @interface */
        [self judgeLocationLine:self.interface idx:idx bufferString:obj judgeString:@"@interface"];
        [self judgeLocationLine:self.implementation idx:idx bufferString:obj judgeString:@"@implementation"];
        [self judgeLocationLine:nil idx:idx bufferString:obj judgeString:@"@end"];
        
        /** set */
        [self judgeLocationArray:self.setArray idx:idx bufferString:obj judgeString:@"-(void)set"];
        
        /** get */
        if (self.propertyArray.count > 0) {
            if ([obj.removeSpaces hasPrefix:@"-(void)"]) return;
            NSString *_attribute = obj.copy;
            _attribute = [_attribute componentsSeparatedByString:@"{"].firstObject;
            _attribute = [_attribute componentsSeparatedByString:@")"].lastObject.removeSpaces;
            [self.propertyArray enumerateObjectsUsingBlock:^(LineObj * _Nonnull lineObj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString * string = lineObj.lingString;
                NSString * attribute = string.getAttribute;
                if ([_attribute isEqualToString:attribute]) [self.getArray addObject:_attribute];
            }];
        }
        
        
        if ([obj containsString:@"R-R"]) {
            NSString *string = obj.mutableCopy;
            string = [string stringByReplacingOccurrencesOfString:@"R-R" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"*" withString:@""];
            self.replaceString = string.copy;
        }
        
    }];
    
    return self;
}

/** 判断位置 多个 */
- (void)judgeLocationArray:(NSMutableArray *)array idx:(NSInteger)idx bufferString:(NSString *)bufferString judgeString:(NSString *)judgeString {
    NSString * bufferS = bufferString.removeSpaces;
        
    /** 包含 */
    if ([bufferS containsString:judgeString] ) {
        
        /** set */
        if ([judgeString isEqualToString:@"-(void)set"]) {
            bufferS = [bufferS stringByReplacingOccurrencesOfString:@"-(void)set" withString:@""];
            bufferS = [[bufferS componentsSeparatedByString:@":"] firstObject];
            
            NSString * judge = @"";
            for (int i = 0; i < bufferS.length; i++) {
                NSString * s = [bufferS substringWithRange:NSMakeRange(i, 1)];
                if (!i) s = s.lowercaseString;
                judge = [judge stringByAppendingString:s];
            }
            
            LineObj * line = [LineObj lineObj:judge currentLine:idx + 1];
            line.startLine = idx;
            line.endLine = idx;
            [array addObject:line];
        } else {
            [array addObject:[LineObj lineObj:bufferString currentLine:idx]];
        }
    }
}

/** 单个 */
- (void)judgeLocationLine:(LineObj *)line idx:(NSInteger)idx bufferString:(NSString *)bufferString judgeString:(NSString *)judgeString {
    NSString * bufferS = bufferString.removeSpaces;
    
    if (([judgeString isEqualToString:@"@interface"] && [bufferString containsString:judgeString]) ||
        ([judgeString isEqualToString:@"@implementation"] && [bufferString containsString:judgeString])) {
        self.currentJudge = line;
    }
    
    if ([judgeString isEqualToString:@"@end"] && [bufferString containsString:judgeString]) {
        self.currentJudge.endLine = idx;
    }
    
    if (line == nil) return;
    if ([bufferS containsString:judgeString])  {
        line.startLine = idx;
        line.endLine = idx;
        line.currentLine = idx + 1;
    }
}

//数组确定位置
- (void)judgeLocationArray:(NSMutableArray <LineObj *>*)array Line:(LineObj *)line {
    if (array.count == 0) return;
    LineObj * firstObj = array.firstObject;
    LineObj * lastObj = array.lastObject;
    line.startLine = firstObj.currentLine;
    line.endLine = lastObj.currentLine;
    line.currentLine = line.endLine + 1;
}

//- ()


@end

@implementation LineObj
+ (instancetype)lineObj:(NSString *)lingString currentLine:(NSInteger)currentLine {
    LineObj *lineObj = [LineObj new];
    lineObj.lingString = lingString;
    lineObj.currentLine = currentLine;
    return lineObj;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"{ %@ : %zd }", self.lingString, self.startLine];
}
@end
