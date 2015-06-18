//
//  SymbolicationPlugin.m
//  SymbolicationPlugin
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Mahesh R Shanbhag
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "SymbolicationPlugin.h"
#import "RootController.h"

@interface SymbolicationPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong, readwrite) RootController *rootController;

@end

@implementation SymbolicationPlugin

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
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

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti {
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Symbolicate" action:@selector(symbolicateMenuAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)symbolicateMenuAction
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
