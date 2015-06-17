//
//  SymbolicationPlugin.m
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 01/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//

#import "SymbolicationPlugin.h"
#import "RootController.h"

@interface SymbolicationPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong, readwrite) RootController *rootController;

@end

@implementation SymbolicationPlugin

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Symbolicate" action:@selector(symbolicateMenuAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

// Sample Action, for menu item:
- (void)symbolicateMenuAction
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.mahesh.SymbolicationPlugin"];
    if([bundle pathForResource:@"RootController" ofType:@"nib"] == nil) {
        self.rootController = nil;
        self.mainWindowController = nil;
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Cannot find 'Symbolicate' plugin bundle."];
        [alert setInformativeText:@"Please clean and re-build the plugin and restart Xcode to use the plugin."];
        [alert runModal];
    }
    else {
        
        if(self.mainWindowController == nil) {
            self.mainWindowController = [[MainWindow alloc] initWithWindowNibName:NSStringFromClass([MainWindow class])];
            self.rootController = [[RootController alloc] initWithNibName:@"RootController" bundle:bundle];
            self.rootController.view.bounds = [(NSView *)self.mainWindowController.window.contentView bounds];
            [self.rootController.view setAutoresizingMask:(NSViewHeightSizable|NSViewWidthSizable)];
            
            self.mainWindowController.contentViewController = self.rootController;
            
        }
        
        [self.mainWindowController.window makeKeyAndOrderFront:self];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
