//
//  Macros.h
//  DinpayPurse
//
//  Created by Mac on 17/1/3.
//  Copyright © 2017年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef Macros_h
#define Macros_h

//屏幕frame
#define KRect ([UIScreen mainScreen].bounds)

//屏幕宽高
#define KWidth [UIScreen mainScreen].bounds.size.width
#define KHeight [UIScreen mainScreen].bounds.size.height
#define KScale  [UIScreen mainScreen].scale

//字体
#define KFont(f) ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 8, .minorVersion = 2, .patchVersion = 0}]) ?\
([UIFont systemFontOfSize:f weight:UIFontWeightRegular]) : \
([UIFont systemFontOfSize:f])

#define KIPHONE_X (KHeight == 812.0f) ? YES : NO
#define KBarHeight ((KIPHONE_X) ? 88.0f : 64.0f)

//颜色(RGB)
#define KRGBColor(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1]
#define KRGBAColor(r, g, b, a) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:(a)]

//获取系统版本
#define KIOS_Version [[[UIDevice currentDevice] systemVersion] floatValue]
#define KCurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//获取当前语言
#define KCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//Library 路径
#define KLibraryboxPath NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject

//强弱引用
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

//Window AppDelegate 通知中心和UserDefaults
#define KWindow [[[UIApplication sharedApplication] delegate] window]
#define KAppDelegate ((AppDelegate *)([UIApplication sharedApplication].delegate))
#define KNotificationCenter [NSNotificationCenter defaultCenter]
#define KUserDefaults [NSUserDefaults standardUserDefaults]

// 颜色(0xFFFFFF) 不用带 0x 和 @""
#define COLOR_WITH_HEX(hexValue) [UIColor colorWithRed:((float)((0x##hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((0x##hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(0x##hexValue & 0xFF)) / 255.0 alpha:1.0f]

//颜色
#define BlackColor       [UIColor blackColor]
#define DarkGrayColor    [UIColor darkGrayColor]
#define LightGrayColor   [UIColor lightGrayColor]
#define WhiteColor       [UIColor whiteColor]
#define RedColor         [UIColor redColor]
#define BlueColor        [UIColor blueColor]
#define GreenColor       [UIColor greenColor]
#define CyanColor        [UIColor cyanColor]
#define YellowColor      [UIColor yellowColor]
#define MagentaColor     [UIColor magentaColor]
#define OrangeColor      [UIColor orangeColor]
#define PurpleColor      [UIColor purpleColor]
#define BrownColor       [UIColor brownColor]
#define ClearColor       [UIColor clearColor]
#define GrayColor        [UIColor grayColor]

//获取当前系统时间戳
#define KGetCurentTime [NSString stringWithFormat:@"%zd", (long)[[NSDate date] timeIntervalSince1970]]

//打印
#ifdef DEBUG
#define __NSLog(FORMAT, ...)                                                                                                                                                                         \
fprintf(stderr, "%s  %d行 ------>:\t%s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define KNSLog(...) __NSLog(@"%@", KMASBoxValue(__VA_ARGS__));

#else

#define __NSLog(FORMAT, ...) nil;
#define NSLog(...) nil;
#define KNSLog(...) nil;
#endif

//push
#define KPush(Class)\
Class* controller = [Class new];\
controller.hidesBottomBarWhenPushed = YES;\
[self.navigationController pushViewController:controller animated:YES];

#define KPushController(viewController) \
viewController.hidesBottomBarWhenPushed = YES;\
[self.navigationController pushViewController:viewController animated:YES];

#define KPoP [self.navigationController popViewControllerAnimated:YES];
#define KMASBoxValue(value) aMASBoxValue(@encode(__typeof__(value)), (value))

#define KiOS9 [[UIDevice currentDevice] systemVersion].floatValue >= 9.0
#define Kiphone5 (CGRectGetHeight([UIScreen mainScreen].bounds) == 568.0)
#define KiPhone6 (CGRectGetHeight([UIScreen mainScreen].bounds) == 667.0)
#define KiPhone6P ([UIScreen mainScreen].bounds.size.width > 400.0)


////线程
//static inline void Kdispatch_async_on_main_queue(void (^block)(void)) {
//    dispatch_async(dispatch_get_main_queue(), block);
//}
//static inline void Kdispatch_async_on_global_queue(void (^block)(void)) {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
//}
//static inline void Kdispatch_after_main_queue(CGFloat t, void (^block)(void)) {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
//}

//block
typedef void (^Void_Block)(void);
typedef BOOL (^Bool_Block)(void);
typedef int  (^Int_Block) (void);
typedef id   (^ID_Block)  (void);

typedef void (^Void_Block_Bool)(BOOL success);
typedef void (^Void_Block_int)(NSInteger idx);
typedef BOOL (^Bool_Block_int)(NSInteger idx);
typedef int  (^Int_Block_int) (NSInteger idx);
typedef id   (^ID_Block_int)  (NSInteger idx);

typedef void (^Void_Block_string)(NSString *);
typedef BOOL (^Bool_Block_string)(NSString *);
typedef int  (^Int_Block_string) (NSString *);
typedef id   (^ID_Block_string)  (NSString *);

typedef void (^Void_Block_id)(id);
typedef BOOL (^Bool_Block_id)(id);
typedef int  (^Int_Block_id) (id);
typedef id   (^ID_Block_id)  (id);


//将括号内的类型转化成id类型
static inline id aMASBoxValue(const char *type, ...) {
    va_list v;
    va_start(v, type);
    id obj = nil;
    if (strcmp(type, @encode(id)) == 0) {
        id actual = va_arg(v, id);
        obj = actual;
    } else if (strcmp(type, @encode(CGPoint)) == 0) {
        CGPoint actual = (CGPoint)va_arg(v, CGPoint);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(CGSize)) == 0) {
        CGSize actual = (CGSize)va_arg(v, CGSize);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(double)) == 0) {
        double actual = (double)va_arg(v, double);
        obj = [NSNumber numberWithDouble:actual];
    } else if (strcmp(type, @encode(float)) == 0) {
        float actual = (float)va_arg(v, double);
        obj = [NSNumber numberWithFloat:actual];
    } else if (strcmp(type, @encode(int)) == 0) {
        int actual = (int)va_arg(v, int);
        obj = [NSNumber numberWithInt:actual];
    } else if (strcmp(type, @encode(long)) == 0) {
        long actual = (long)va_arg(v, long);
        obj = [NSNumber numberWithLong:actual];
    } else if (strcmp(type, @encode(long long)) == 0) {
        long long actual = (long long)va_arg(v, long long);
        obj = [NSNumber numberWithLongLong:actual];
    } else if (strcmp(type, @encode(short)) == 0) {
        short actual = (short)va_arg(v, int);
        obj = [NSNumber numberWithShort:actual];
    } else if (strcmp(type, @encode(char)) == 0) {
        char actual = (char)va_arg(v, int);
        obj = [NSNumber numberWithChar:actual];
    } else if (strcmp(type, @encode(bool)) == 0) {
        bool actual = (bool)va_arg(v, int);
        obj = [NSNumber numberWithBool:actual];
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        unsigned char actual = (unsigned char)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedChar:actual];
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        unsigned int actual = (unsigned int)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedInt:actual];
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        unsigned long actual = (unsigned long)va_arg(v, unsigned long);
        obj = [NSNumber numberWithUnsignedLong:actual];
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        unsigned long long actual = (unsigned long long)va_arg(v, unsigned long long);
        obj = [NSNumber numberWithUnsignedLongLong:actual];
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        unsigned short actual = (unsigned short)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedShort:actual];
    }
    va_end(v);
    return obj;
}

//单例
#define SINGLETON_FOR_INTERFACE(className) \
+ (className *)shared##className;

#define SINGLETON_FOR_IMPLEMENTATION(className) \
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}

//归档解归档
#define KSERIALIZE_CODER_DECODER()     \
\
- (id)initWithCoder:(NSCoder *)coder    \
{   \
Class cls = [self class];   \
while (cls != [NSObject class]) {   \
BOOL bIsSelfClass = (cls == [self class]);  \
unsigned int iVarCount = 0; \
unsigned int propVarCount = 0;  \
unsigned int sharedVarCount = 0;    \
Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL; \
objc_property_t *propList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propVarCount);  \
sharedVarCount = bIsSelfClass ? iVarCount : propVarCount;   \
\
for (int i = 0; i < sharedVarCount; i++) {  \
const char *varName = bIsSelfClass ? ivar_getName(*(ivarList + i)) : property_getName(*(propList + i)); \
NSString *key = [NSString stringWithUTF8String:varName];   \
id varValue = [coder decodeObjectForKey:key];   \
if (varValue) { \
[self setValue:varValue forKey:key];    \
}   \
}   \
free(ivarList); \
free(propList); \
cls = class_getSuperclass(cls); \
}   \
return self;    \
}   \
\
- (void)encodeWithCoder:(NSCoder *)coder    \
{   \
Class cls = [self class];   \
while (cls != [NSObject class]) {   \
BOOL bIsSelfClass = (cls == [self class]);  \
unsigned int iVarCount = 0; \
unsigned int propVarCount = 0;  \
unsigned int sharedVarCount = 0;    \
Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL; \
objc_property_t *propList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propVarCount);\
sharedVarCount = bIsSelfClass ? iVarCount : propVarCount;   \
\
for (int i = 0; i < sharedVarCount; i++) {  \
const char *varName = bIsSelfClass ? ivar_getName(*(ivarList + i)) : property_getName(*(propList + i)); \
NSString *key = [NSString stringWithUTF8String:varName];    \
id varValue = [self valueForKey:key];   \
if (varValue) { \
[coder encodeObject:varValue forKey:key];   \
}   \
}   \
free(ivarList); \
free(propList); \
cls = class_getSuperclass(cls); \
}   \
}
#endif /* Macros_h */
