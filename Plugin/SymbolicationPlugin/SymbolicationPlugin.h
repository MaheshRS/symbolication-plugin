//
//  SymbolicationPlugin.h
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 01/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "MainWindow.h"

@class SymbolicationPlugin;

static SymbolicationPlugin *sharedPlugin;

@interface SymbolicationPlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@property (nonatomic, strong) MainWindow* mainWindowController;

@end