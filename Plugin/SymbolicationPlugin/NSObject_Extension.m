//
//  NSObject_Extension.m
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 01/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//


#import "NSObject_Extension.h"
#import "SymbolicationPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[SymbolicationPlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
