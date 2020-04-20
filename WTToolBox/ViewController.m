//
//  ViewController.m
//  WTToolBox
//
//  Created by wintelsui on 16/8/30.
//  Copyright © 2016年 wintelsui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSArray * arrays;
@property (nonatomic, assign) BOOL head;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
              
    // Do any additional setup after loading the view.
    
    //NSLog(@"结果:\n%@",[self deleteFirstSpace:@"    3"]);
    
    NSLog(@"结果:\n%@",[self deleteFirstSpace2:@"- (NSDictionary *)handlers ddddd:(NSDictionary *)aaaaa asdasd:(NSIntger) number"]);
    
    
}

- (NSString *)deleteFirstSpace2:(NSString *)oldString{
    
    return nil;
}
- (NSString *)deleteFirstSpace:(NSString *)oldString{
    if (oldString == nil || oldString.length == 0) {
        return @"";
    }
    NSString *newString = oldString;
    while (newString.length > 0) {
        if ([newString hasPrefix:@" "]) {
            if (newString.length > 1) {
                newString = [newString substringFromIndex:1];
            } else {
                newString = @"";
            }
        } else {
            break;
        }
    }
    return newString;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSArray *)arrays {
    if (!_arrays) _arrays = @[].mutableCopy;
    return _arrays;
}

- (NSString *)name {
    // if (!_name) _name = @;
    return _name;
}
@end
